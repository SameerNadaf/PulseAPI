//
//  ContentView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}
