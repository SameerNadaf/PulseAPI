//
//  EndpointsScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct EndpointsScreen: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = EndpointsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.endpoints.isEmpty {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading endpoints...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.endpoints.isEmpty {
                // Empty state
                ContentUnavailableView(
                    "No Endpoints",
                    systemImage: "server.rack",
                    description: Text("Add an endpoint to start monitoring your APIs")
                )
            } else {
                // Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredEndpoints) { endpoint in
                        EndpointRowCard(
                                name: endpoint.name,
                                url: endpoint.url,
                                status: endpoint.status,
                                latency: endpoint.latencyMs
                            )
                            .onTapGesture {
                                router.navigateToEndpoint(id: endpoint.id)
                            }
                            .contextMenu {
                                Button {
                                    Task { await viewModel.toggleEndpointActive(endpoint) }
                                } label: {
                                    Label(
                                        endpoint.isActive ? "Pause Monitoring" : "Resume Monitoring",
                                        systemImage: endpoint.isActive ? "pause.circle" : "play.circle"
                                    )
                                }
                                
                                Divider()
                                
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteEndpoint(endpoint) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
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
        .navigationTitle("Endpoints")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchText, prompt: "Search endpoints")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadEndpoints()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.showAddEndpoint()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
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
}

#Preview {
    NavigationStack {
        EndpointsScreen()
    }
    .environmentObject(AppRouter())
}

