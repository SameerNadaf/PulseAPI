//
//  AppRouter.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

// MARK: - Route Definition
enum AppRoute: Hashable {
    case dashboard
    case endpoints
    case incidents
    case settings
}

// MARK: - App Router
@MainActor
final class AppRouter: ObservableObject {
    @Published var currentRoute: AppRoute = .dashboard
    @Published var navigationPath = NavigationPath()
    
    // MARK: - Navigation Actions
    func navigate(to route: AppRoute) {
        currentRoute = route
    }
    
    func push(_ route: AppRoute) {
        navigationPath.append(route)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
