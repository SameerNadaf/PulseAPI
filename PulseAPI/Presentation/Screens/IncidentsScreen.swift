//
//  IncidentsScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct IncidentsScreen: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = IncidentsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(IncidentsViewModel.Filter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if viewModel.isLoading && viewModel.incidents.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading incidents...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredIncidents.isEmpty {
                ContentUnavailableView(
                    "No Incidents",
                    systemImage: "checkmark.shield.fill",
                    description: Text(emptyDescription)
                )
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredIncidents) { incident in
                            IncidentRowCard(
                                title: incident.title,
                                endpoint: incident.endpointId,
                                severity: incident.severity,
                                startedAt: incident.startedAt,
                                status: incident.status
                            )
                            .onTapGesture {
                                router.showIncidentDetail(id: incident.id)
                            }
                            .contextMenu {
                                if incident.status != .resolved {
                                    Button {
                                        Task {
                                            await viewModel.resolveIncident(incident)
                                        }
                                    } label: {
                                        Label("Mark Resolved", systemImage: "checkmark.circle")
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if incident.status != .resolved {
                                    Button {
                                        Task {
                                            await viewModel.resolveIncident(incident)
                                        }
                                    } label: {
                                        Label("Resolve", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
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
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadIncidents()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("Retry") {
                Task { await viewModel.refresh() }
            }
            Button("Dismiss", role: .cancel) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Unknown error")
        }
    }
    
    private var emptyDescription: String {
        switch viewModel.selectedFilter {
        case .active:
            return "All systems are operating normally"
        case .resolved:
            return "No resolved incidents to show"
        case .all:
            return "No incidents recorded yet"
        }
    }
}

#Preview {
    NavigationStack {
        IncidentsScreen()
    }
    .environmentObject(AppRouter())
}

