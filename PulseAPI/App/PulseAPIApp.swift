//
//  PulseAPIApp.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

@main
struct PulseAPIApp: App {
    @StateObject private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
        }
    }
}

// MARK: - Root Content View
struct ContentView: View {
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        Group {
            switch router.currentRoute {
            case .dashboard:
                Text("Dashboard")
            case .endpoints:
                Text("Endpoints")
            case .incidents:
                Text("Incidents")
            case .settings:
                Text("Settings")
            }
        }
    }
}
