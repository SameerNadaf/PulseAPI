//
//  DashboardScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject private var router: AppRouter
    
    // TODO: Replace with ViewModel in Phase 2
    @State private var overallHealth: Int = 98
    @State private var endpointCount: Int = 5
    @State private var activeIncidents: Int = 1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Health Card
                OverallHealthCard(
                    healthPercentage: overallHealth,
                    endpointCount: endpointCount,
                    activeIncidents: activeIncidents
                )
                .padding(.horizontal)
                
                // Quick Stats Row
                QuickStatsRow()
                    .padding(.horizontal)
                
                // Endpoints Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Monitored Endpoints", action: {
                        router.switchTab(to: .endpoints)
                    })
                    
                    // Placeholder endpoint cards
                    ForEach(0..<3, id: \.self) { index in
                        EndpointRowCard(
                            name: "API Endpoint \(index + 1)",
                            url: "api.example.com/v1/endpoint\(index + 1)",
                            status: index == 0 ? .degraded : .healthy,
                            latency: Double.random(in: 45...250)
                        )
                        .onTapGesture {
                            router.showEndpointDetail(id: "endpoint-\(index)")
                        }
                    }
                }
                .padding(.horizontal)
                
                // Recent Incidents Section
                if activeIncidents > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Active Incidents", action: {
                            router.switchTab(to: .incidents)
                        })
                        
                        IncidentRowCard(
                            title: "Latency Spike Detected",
                            endpoint: "Payment API",
                            severity: .major,
                            startedAt: Date().addingTimeInterval(-3600)
                        )
                        .onTapGesture {
                            router.switchTab(to: .incidents)
                            router.showIncidentDetail(id: "incident-1")
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
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
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                icon: "clock.fill",
                value: "125ms",
                label: "Avg Latency",
                color: .blue
            )
            
            QuickStatCard(
                icon: "checkmark.circle.fill",
                value: "99.8%",
                label: "Uptime",
                color: .green
            )
            
            QuickStatCard(
                icon: "exclamationmark.triangle.fill",
                value: "0.2%",
                label: "Error Rate",
                color: .orange
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
