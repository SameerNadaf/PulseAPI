//
//  EndpointsScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct EndpointsScreen: View {
    @EnvironmentObject private var router: AppRouter
    
    // TODO: Replace with ViewModel in Phase 2
    @State private var endpoints: [EndpointPreview] = EndpointPreview.samples
    @State private var searchText: String = ""
    
    private var filteredEndpoints: [EndpointPreview] {
        if searchText.isEmpty {
            return endpoints
        }
        return endpoints.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.url.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredEndpoints) { endpoint in
                    EndpointRowCard(
                        name: endpoint.name,
                        url: endpoint.url,
                        status: endpoint.status,
                        latency: endpoint.latency
                    )
                    .onTapGesture {
                        router.navigateToEndpoint(id: endpoint.id)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Endpoints")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search endpoints")
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
    }
}

// MARK: - Endpoint Preview (temporary model for UI)
struct EndpointPreview: Identifiable {
    let id: String
    let name: String
    let url: String
    let status: EndpointStatus
    let latency: Double
    
    static let samples: [EndpointPreview] = [
        EndpointPreview(id: "1", name: "User API", url: "api.example.com/v1/users", status: .healthy, latency: 89),
        EndpointPreview(id: "2", name: "Payment Service", url: "payments.example.com/api/charge", status: .degraded, latency: 450),
        EndpointPreview(id: "3", name: "Auth Endpoint", url: "auth.example.com/oauth/token", status: .healthy, latency: 120),
        EndpointPreview(id: "4", name: "Notifications", url: "notify.example.com/v2/push", status: .healthy, latency: 65),
        EndpointPreview(id: "5", name: "Search API", url: "search.example.com/query", status: .down, latency: 0),
    ]
}

#Preview {
    NavigationStack {
        EndpointsScreen()
    }
    .environmentObject(AppRouter())
}
