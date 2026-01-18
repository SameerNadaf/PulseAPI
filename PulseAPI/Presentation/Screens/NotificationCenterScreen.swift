//
//  NotificationCenterScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct NotificationCenterScreen: View {
    @StateObject private var notificationService = NotificationService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if notificationService.notifications.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(notificationService.notifications) { notification in
                            NotificationRow(notification: notification)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        notificationService.delete(notification.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    if !notification.isRead {
                                        Button {
                                            notificationService.markAsRead(notification.id)
                                        } label: {
                                            Label("Read", systemImage: "envelope.open")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !notificationService.notifications.isEmpty {
                        Menu {
                            Button {
                                notificationService.markAllAsRead()
                            } label: {
                                Label("Mark All Read", systemImage: "checkmark.circle")
                            }
                            
                            Button(role: .destructive) {
                                notificationService.clearAll()
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // For demo/testing purposes
                        notificationService.addTestNotification()
                    } label: {
                        Image(systemName: "plus.circle") // Hidden debug feature
                            .opacity(0)
                    }
                    .disabled(true) // Disable for production
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("No Notifications")
                    .font(.title2.bold())
                Text("All caught up! You'll see alerts here when something important happens.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if notificationService.authorizationStatus == .denied {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Enable Notifications in Settings")
                        .fontWeight(.medium)
                }
                .padding(.top)
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    @StateObject private var service = NotificationService.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Circle()
                .fill(notification.type.color.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: notification.type.icon)
                        .foregroundStyle(notification.type.color)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text(timeAgo(notification.timestamp))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Make entire row tappable
        .onTapGesture {
            service.markAsRead(notification.id)
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NotificationCenterScreen()
}
