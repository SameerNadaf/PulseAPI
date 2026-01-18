//
//  NotificationService.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import UserNotifications

struct AppNotification: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let timestamp: Date
    let type: NotificationType
    let endpointId: String?
    var isRead: Bool
    
    enum NotificationType: String, Codable {
        case incident
        case recovery
        case degradation
        case system
        
        var icon: String {
            switch self {
            case .incident: return "exclamationmark.triangle.fill"
            case .recovery: return "checkmark.circle.fill"
            case .degradation: return "arrow.down.right.circle.fill"
            case .system: return "gearshape.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .incident: return .red
            case .recovery: return .green
            case .degradation: return .orange
            case .system: return .blue
            }
        }
    }
}

@MainActor
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Initialization
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        loadNotifications()
    }
    
    // MARK: - Permissions
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorizationStatus()
            
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Management
    func addNotification(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        saveNotifications()
    }
    
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            saveNotifications()
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        saveNotifications()
    }
    
    func clearAll() {
        notifications.removeAll()
        saveNotifications()
    }
    
    func delete(_ notificationId: String) {
        notifications.removeAll(where: { $0.id == notificationId })
        saveNotifications()
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Persistence
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: "app_notifications")
        }
    }
    
    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: "app_notifications"),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = decoded
        }
    }
    
    // MARK: - Testing
    func addTestNotification() {
        let notification = AppNotification(
            id: UUID().uuidString,
            title: "High Latency Detected",
            body: "Endpoint 'Checkout API' is experiencing high latency (850ms).",
            timestamp: Date(),
            type: .degradation,
            endpointId: nil,
            isRead: false
        )
        addNotification(notification)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        
        let content = notification.request.content
        let userInfo = content.userInfo
        
        // Extract data and create local notification record
        let typeString = userInfo["type"] as? String ?? "system"
        let endpointId = userInfo["endpointId"] as? String
        
        let appNotification = AppNotification(
            id: UUID().uuidString,
            title: content.title,
            body: content.body,
            timestamp: Date(),
            type: AppNotification.NotificationType(rawValue: typeString) ?? .system,
            endpointId: endpointId,
            isRead: false
        )
        
        addNotification(appNotification)
        
        return [.banner, .sound, .list]
    }
    
    // Handle notification user interaction (tap)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        
        // TODO: Handle deep linking based on userInfo
        // e.g. Navigate to specific endpoint or incident
    }
}
