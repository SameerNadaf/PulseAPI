//
//  FirebaseAuthService.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case googleSignInFailed
    case noRootViewController
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .userNotFound:
            return "No account found with this email"
        case .wrongPassword:
            return "Incorrect password"
        case .networkError:
            return "Network error. Please check your connection"
        case .googleSignInFailed:
            return "Google Sign-In failed. Please try again"
        case .noRootViewController:
            return "Unable to present sign-in screen"
        case .unknown(let message):
            return message
        }
    }
    
    static func from(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard nsError.domain == AuthErrorDomain else {
            return .unknown(error.localizedDescription)
        }
        
        switch AuthErrorCode(rawValue: nsError.code) {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

@MainActor
final class FirebaseAuthService: ObservableObject {
    static let shared = FirebaseAuthService()
    
    // MARK: - Published State
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = false
    @Published private(set) var isInitializing = true
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                self?.isInitializing = false
            }
        }
    }
    
    // MARK: - Sign Up with Email
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
        } catch {
            throw AuthError.from(error)
        }
    }
    
    // MARK: - Sign In with Email
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
        } catch {
            throw AuthError.from(error)
        }
    }
    
    // MARK: - Sign In with Google
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.googleSignInFailed
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.googleSignInFailed
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            isAuthenticated = true
        } catch {
            if (error as NSError).code == GIDSignInError.canceled.rawValue {
                // User cancelled, don't throw error
                return
            }
            throw AuthError.googleSignInFailed
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError.from(error)
        }
    }
    
    // MARK: - Get ID Token (for backend API)
    func getIDToken() async throws -> String {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        
        return try await user.getIDToken()
    }
    
    // MARK: - Refresh Token
    func refreshToken() async throws -> String {
        guard let user = currentUser else {
            throw AuthError.userNotFound
        }
        
        return try await user.getIDToken(forcingRefresh: true)
    }
    
    // MARK: - User Info
    var userEmail: String? {
        currentUser?.email
    }
    
    var userId: String? {
        currentUser?.uid
    }
    
    var displayName: String? {
        currentUser?.displayName
    }
    
    var photoURL: URL? {
        currentUser?.photoURL
    }
}

