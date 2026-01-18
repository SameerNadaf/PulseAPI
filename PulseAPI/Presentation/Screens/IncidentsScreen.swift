//
//  IncidentsScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct IncidentsScreen: View {
    @EnvironmentObject private var router: AppRouter
    
    // TODO: Replace with ViewModel in Phase 2
    @State private var selectedFilter: IncidentFilter = .active
    @State private var incidents: [IncidentPreview] = IncidentPreview.samples
    
    private var filteredIncidents: [IncidentPreview] {
        switch selectedFilter {
        case .active:
            return incidents.filter { $0.status != .resolved }
        case .resolved:
            return incidents.filter { $0.status == .resolved }
        case .all:
            return incidents
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(IncidentFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Incidents List
            if filteredIncidents.isEmpty {
                ContentUnavailableView(
                    "No Incidents",
                    systemImage: "checkmark.shield.fill",
                    description: Text("All systems are operating normally")
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredIncidents) { incident in
                            IncidentRowCard(
                                title: incident.title,
                                endpoint: incident.endpointName,
                                severity: incident.severity,
                                startedAt: incident.startedAt,
                                status: incident.status
                            )
                            .onTapGesture {
                                router.showIncidentDetail(id: incident.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Incidents")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Incident Filter
enum IncidentFilter: String, CaseIterable {
    case active = "Active"
    case resolved = "Resolved"
    case all = "All"
}

// MARK: - Incident Preview (temporary model for UI)
struct IncidentPreview: Identifiable {
    let id: String
    let title: String
    let endpointName: String
    let severity: IncidentSeverity
    let status: IncidentStatus
    let startedAt: Date
    
    static let samples: [IncidentPreview] = [
        IncidentPreview(
            id: "1",
            title: "Latency Spike Detected",
            endpointName: "Payment Service",
            severity: .major,
            status: .investigating,
            startedAt: Date().addingTimeInterval(-3600)
        ),
        IncidentPreview(
            id: "2",
            title: "High Error Rate",
            endpointName: "Search API",
            severity: .critical,
            status: .active,
            startedAt: Date().addingTimeInterval(-7200)
        ),
        IncidentPreview(
            id: "3",
            title: "Timeout Issues",
            endpointName: "Notifications",
            severity: .minor,
            status: .resolved,
            startedAt: Date().addingTimeInterval(-86400)
        ),
    ]
}

#Preview {
    NavigationStack {
        IncidentsScreen()
    }
    .environmentObject(AppRouter())
}
