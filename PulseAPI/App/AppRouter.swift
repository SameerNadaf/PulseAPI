//
//  AppRouter.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

// MARK: - Main Route Definition
enum AppRoute: Hashable {
    case dashboard
    case endpoints
    case incidents
    case settings
}

// MARK: - Endpoint Sub-Routes
enum EndpointRoute: Hashable {
    case detail(String)  // endpointId
    case add
}

// MARK: - Incident Sub-Routes
enum IncidentRoute: Hashable {
    case detail(String)  // incidentId
}

// MARK: - App Router
@MainActor
final class AppRouter: ObservableObject {
    // Current main tab
    @Published var currentRoute: AppRoute = .dashboard
    
    // Per-tab navigation paths
    @Published var dashboardPath = NavigationPath()
    @Published var endpointsPath = NavigationPath()
    @Published var incidentsPath = NavigationPath()
    
    // MARK: - Tab Navigation
    func switchTab(to tab: AppRoute) {
        currentRoute = tab
    }
    
    // MARK: - Dashboard Navigation
    func showEndpointDetail(id: String) {
        dashboardPath.append(EndpointRoute.detail(id))
    }
    
    // MARK: - Endpoints Navigation
    func navigateToEndpoint(id: String) {
        endpointsPath.append(EndpointRoute.detail(id))
    }
    
    func showAddEndpoint() {
        endpointsPath.append(EndpointRoute.add)
    }
    
    // MARK: - Incidents Navigation
    func showIncidentDetail(id: String) {
        incidentsPath.append(IncidentRoute.detail(id))
    }
    
    // MARK: - Pop Navigation
    func popDashboard() {
        guard !dashboardPath.isEmpty else { return }
        dashboardPath.removeLast()
    }
    
    func popEndpoints() {
        guard !endpointsPath.isEmpty else { return }
        endpointsPath.removeLast()
    }
    
    func popIncidents() {
        guard !incidentsPath.isEmpty else { return }
        incidentsPath.removeLast()
    }
    
    // MARK: - Reset Navigation
    func popToRoot() {
        dashboardPath = NavigationPath()
        endpointsPath = NavigationPath()
        incidentsPath = NavigationPath()
    }
}
