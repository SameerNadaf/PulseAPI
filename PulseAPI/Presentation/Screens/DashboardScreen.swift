//
//  DashboardScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.dashboard == nil {
                // Initial loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading dashboard...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                VStack(spacing: 20) {
                    // Overall Health Card
                    OverallHealthCard(
                        healthPercentage: viewModel.overallHealth,
                        endpointCount: viewModel.endpointCount,
                        activeIncidents: viewModel.activeIncidents
                    )
                    .padding(.horizontal)
                    
                    // Quick Stats Row
                    QuickStatsRow(
                        healthyCount: viewModel.healthyCount,
                        degradedCount: viewModel.degradedCount,
                        downCount: viewModel.downCount
                    )
                    .padding(.horizontal)
                    
                    // Endpoints Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Monitored Endpoints", action: {
                            router.switchTab(to: .endpoints)
                        })
                        
                        if viewModel.endpoints.isEmpty {
                            EmptyEndpointsView()
                        } else {
                            ForEach(viewModel.endpoints.prefix(5)) { endpoint in
                                EndpointRowCard(
                                    name: endpoint.name,
                                    url: endpoint.id,
                                    status: endpoint.status,
                                    latency: endpoint.latency ?? 0
                                )
                                .onTapGesture {
                                    router.showEndpointDetail(id: endpoint.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Incidents Section
                    if !viewModel.recentIncidents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Active Incidents", action: {
                                router.switchTab(to: .incidents)
                            })
                            
                            ForEach(viewModel.recentIncidents.prefix(3)) { incident in
                                IncidentRowCard(
                                    title: incident.title,
                                    endpoint: incident.endpointId,
                                    severity: incident.severity,
                                    startedAt: incident.startedAt,
                                    status: incident.status
                                )
                                .onTapGesture {
                                    router.switchTab(to: .incidents)
                                    router.showIncidentDetail(id: incident.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadDashboard()
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

// MARK: - Empty Endpoints View
struct EmptyEndpointsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No endpoints yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Add an endpoint to start monitoring")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Overall Health Card
struct OverallHealthCard: View {
    let healthPercentage: Int
    let endpointCount: Int
    let activeIncidents: Int
    
    private var healthColor: Color {
        if healthPercentage >= 95 { return .green }
        if healthPercentage >= 80 { return .yellow }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Health Ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(healthPercentage) / 100)
                    .stroke(healthColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.5), value: healthPercentage)
                
                VStack(spacing: 2) {
                    Text("\(healthPercentage)%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(healthColor)
                    Text("Health")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats Row
            HStack(spacing: 32) {
                StatItem(value: "\(endpointCount)", label: "Endpoints")
                
                Divider()
                    .frame(height: 32)
                
                StatItem(
                    value: "\(activeIncidents)",
                    label: "Incidents",
                    valueColor: activeIncidents > 0 ? .orange : .primary
                )
            }
        }
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    var valueColor: Color = .primary
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(valueColor)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    var healthyCount: Int = 0
    var degradedCount: Int = 0
    var downCount: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                icon: "checkmark.circle.fill",
                value: "\(healthyCount)",
                label: "Healthy",
                color: .green
            )
            
            QuickStatCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(degradedCount)",
                label: "Degraded",
                color: .orange
            )
            
            QuickStatCard(
                icon: "xmark.circle.fill",
                value: "\(downCount)",
                label: "Down",
                color: .red
            )
        }
    }
}

// MARK: - Quick Stat Card
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.subheadline.bold())
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            if let action {
                Button("See All", action: action)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardScreen()
    }
    .environmentObject(AppRouter())
}
