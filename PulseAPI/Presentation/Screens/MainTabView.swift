//
//  MainTabView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var selectedTab: AppRoute = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationStack(path: $router.dashboardPath) {
                DashboardScreen()
                    .navigationDestination(for: EndpointRoute.self) { route in
                        switch route {
                        case .detail(let endpointId):
                            EndpointDetailScreen(endpointId: endpointId)
                        case .add:
                            AddEndpointScreen()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                NotificationCenterScreen()
                            } label: {
                                Label("Notifications", systemImage: "bell")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            .tag(AppRoute.dashboard)
            
            // Endpoints Tab
            NavigationStack(path: $router.endpointsPath) {
                EndpointsScreen()
                    .navigationDestination(for: EndpointRoute.self) { route in
                        switch route {
                        case .detail(let endpointId):
                            EndpointDetailScreen(endpointId: endpointId)
                        case .add:
                            AddEndpointScreen()
                        }
                    }
            }
            .tabItem {
                Label("Endpoints", systemImage: "server.rack")
            }
            .tag(AppRoute.endpoints)
            
            // Incidents Tab
            NavigationStack(path: $router.incidentsPath) {
                IncidentsScreen()
                    .navigationDestination(for: IncidentRoute.self) { route in
                        switch route {
                        case .detail(let incidentId):
                            IncidentDetailScreen(incidentId: incidentId)
                        }
                    }
            }
            .tabItem {
                Label("Incidents", systemImage: "exclamationmark.triangle.fill")
            }
            .tag(AppRoute.incidents)
            
            // Settings Tab
            NavigationStack {
                SettingsScreen()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(AppRoute.settings)
        }
        .onChange(of: selectedTab) { _, newTab in
            router.currentRoute = newTab
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
}
