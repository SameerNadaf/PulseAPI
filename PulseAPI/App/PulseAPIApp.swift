//
//  PulseAPIApp.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import FirebaseCore

@main
struct PulseAPIApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize AuthManager early to set up auth state observer
        // This ensures userId is set before any API calls
        _ = AuthManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
