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
    
    private init() {
        // Check if user is already authenticated
        loadStoredUser()
    }
    
    // MARK: - Load Stored User
    private func loadStoredUser() {
        if let userId = try? keychain.readString(for: KeychainKeys.userId) {
            apiClient.userId = userId
            isAuthenticated = true
            
            // Load user profile in background
            Task {
                await refreshUserProfile()
            }
        }
    }
    
    // MARK: - Sign In (simplified - no real auth yet)
    func signIn(userId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Store user ID
        try keychain.save(userId, for: KeychainKeys.userId)
        apiClient.userId = userId
        
        // Fetch user profile
        await refreshUserProfile()
        
        isAuthenticated = true
    }
    
    // MARK: - Sign Out
    func signOut() {
        try? keychain.delete(for: KeychainKeys.userId)
        try? keychain.delete(for: KeychainKeys.authToken)
        try? keychain.delete(for: KeychainKeys.deviceToken)
        
        apiClient.userId = nil
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Refresh User Profile
    func refreshUserProfile() async {
        do {
            let response = try await apiClient.request(
                UsersAPI.me,
                expecting: APIResponse<UserDTO>.self
            )
            currentUser = response.data
        } catch {
            // Silently fail - user might not exist yet
            print("Failed to fetch user profile: \(error)")
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
    
    // MARK: - Guest Mode (for demo/development)
    func signInAsGuest() async {
        let guestId = "guest-\(UUID().uuidString.prefix(8))"
        try? await signIn(userId: guestId)
    }
}
