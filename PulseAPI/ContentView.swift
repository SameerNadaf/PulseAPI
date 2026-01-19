//
//  ContentView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var authService = FirebaseAuthService.shared
    
    var body: some View {
        Group {
            if authService.isInitializing {
                // Splash screen while checking auth state
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        Text("PulseAPI")
                            .font(.title.bold())
                    }
                }
            } else if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginScreen()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isInitializing)
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}

