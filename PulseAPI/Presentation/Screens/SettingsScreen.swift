//
//  SettingsScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var notificationsEnabled: Bool = true
    @State private var criticalAlertsOnly: Bool = false
    
    var body: some View {
        List {
            // Account Section
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("user@example.com")
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("Pro Plan")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 8)
            }
            
            // Subscription Section
            Section("Subscription") {
                NavigationLink {
                    Text("Manage Subscription")
                } label: {
                    Label("Manage Plan", systemImage: "creditcard.fill")
                }
                
                HStack {
                    Label("Endpoints", systemImage: "server.rack")
                    Spacer()
                    Text("3 / 50")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("Expires", systemImage: "calendar")
                    Spacer()
                    Text("Jan 18, 2027")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Appearance Section
            Section("Appearance") {
                Picker(selection: $themeManager.appTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Label(theme.rawValue, systemImage: theme.icon)
                            .tag(theme)
                    }
                } label: {
                    Label("Theme", systemImage: "paintbrush.fill")
                }
            }
            
            // Notifications Section
            Section("Notifications") {
                Toggle(isOn: $notificationsEnabled) {
                    Label("Push Notifications", systemImage: "bell.fill")
                }
                
                Toggle(isOn: $criticalAlertsOnly) {
                    Label("Critical Alerts Only", systemImage: "exclamationmark.triangle.fill")
                }
                .disabled(!notificationsEnabled)
                
                NavigationLink {
                    Text("Notification Settings")
                } label: {
                    Label("Alert Preferences", systemImage: "slider.horizontal.3")
                }
            }
            
            // Monitoring Section
            Section("Monitoring") {
                NavigationLink {
                    Text("Default Probe Settings")
                } label: {
                    Label("Default Settings", systemImage: "gearshape.fill")
                }
                
                NavigationLink {
                    Text("Data Retention")
                } label: {
                    Label("Data Retention", systemImage: "clock.arrow.circlepath")
                }
            }
            
            // About Section
            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle.fill")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                NavigationLink {
                    Text("Privacy Policy")
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                
                NavigationLink {
                    Text("Terms of Service")
                } label: {
                    Label("Terms of Service", systemImage: "doc.text.fill")
                }
                
                Link(destination: URL(string: "mailto:support@pulseapi.dev")!) {
                    Label("Contact Support", systemImage: "envelope.fill")
                }
            }
            
            // Danger Zone
            Section {
                Button(role: .destructive) {
                    // TODO: Sign out
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .environmentObject(ThemeManager())
    }
}

