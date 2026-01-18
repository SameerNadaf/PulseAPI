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
