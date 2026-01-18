//
//  AuthManager.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // MARK: - Published State
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: UserDTO?
    @Published private(set) var isLoading = false
    
    // MARK: - Dependencies
    private let keychain = KeychainService.shared
    private let apiClient = APIClient.shared
    private let firebaseAuth = FirebaseAuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthStateObserver()
    }
    
    // MARK: - Firebase Auth State Observer
    private func setupAuthStateObserver() {
        firebaseAuth.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth in
                self?.isAuthenticated = isAuth
                if isAuth {
                    self?.syncUserWithBackend()
                } else {
                    self?.currentUser = nil
                    self?.apiClient.userId = nil
                }
            }
            .store(in: &cancellables)
        
        firebaseAuth.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let userId = user?.uid {
                    self?.apiClient.userId = userId
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync User with Backend
    private func syncUserWithBackend() {
        Task {
            await refreshUserProfile()
        }
    }
    
    // MARK: - Refresh User Profile
    func refreshUserProfile() async {
        guard firebaseAuth.isAuthenticated else { return }
        
        do {
            let response = try await apiClient.request(
                UsersAPI.me,
                expecting: APIResponse<UserDTO>.self
            )
            currentUser = response.data
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try firebaseAuth.signOut()
            try? keychain.delete(for: KeychainKeys.deviceToken)
            currentUser = nil
            apiClient.userId = nil
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    // MARK: - Register Device Token
    func registerDeviceToken(_ token: String) async {
        do {
            try keychain.save(token, for: KeychainKeys.deviceToken)
            
            _ = try await apiClient.request(
                UsersAPI.registerDeviceToken(token: token),
                expecting: APIResponse<EmptyResponse>.self
            )
        } catch {
            print("Failed to register device token: \(error)")
        }
    }
    
    // MARK: - User Info
    var userEmail: String? {
        firebaseAuth.userEmail
    }
    
    var userId: String? {
        firebaseAuth.userId
    }
}
