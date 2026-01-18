//
//  EndpointDetailScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

struct EndpointDetailScreen: View {
    let endpointId: String
    @EnvironmentObject private var router: AppRouter
    
    // TODO: Replace with ViewModel in Phase 2/3
    @State private var selectedTimeRange: TimeRange = .day
    
    // Reliability Score (Mock)
    let reliabilityScore: Double = 92
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Reliability Score
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Online")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                        
                        Text("Last checked: Just now")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    ReliabilityScoreView(
                        score: reliabilityScore,
                        trend: .improving,
                        size: 80,
                        showLabel: false
                    )
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Charts Section
                VStack(spacing: 16) {
                    LatencyChartView(
                        dataPoints: sampleLatencyData,
                        baseline: 120,
                        height: 200
                    )
                    
                    UptimeChartView(
                        dataPoints: sampleUptimeData,
                        height: 160
                    )
                    
                    ErrorRateChartView(
                        dataPoints: sampleErrorData,
                        height: 160
                    )
                }
                .padding(.horizontal)
                
                // Statistics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(
                        title: "Avg Latency",
                        value: "125ms",
                        icon: "clock.fill",
                        color: .blue
                    )
                    StatCard(
                        title: "P95 Latency",
                        value: "280ms",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                    StatCard(
                        title: "Success Rate",
                        value: "99.8%",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    StatCard(
                        title: "Total Requests",
                        value: "12.4K",
                        icon: "arrow.up.arrow.down",
                        color: .purple
                    )
                }
                .padding(.horizontal)
                
                // Recent Incidents
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Incidents")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    IncidentRowCard(
                        title: "Latency Spike",
                        endpoint: "This endpoint",
                        severity: .minor,
                        startedAt: Date().addingTimeInterval(-86400),
                        status: .resolved
                    )
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Endpoint Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        // Edit action
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        // Pause monitoring
                    } label: {
                        Label("Pause Monitoring", systemImage: "pause.circle")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        // Delete action
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    // MARK: - Sample Data
    private var sampleLatencyData: [LatencyDataPoint] {
        (0..<24).map { hour in
            LatencyDataPoint(
                timestamp: Date().addingTimeInterval(-Double(24 - hour) * 3600),
                latency: Double.random(in: 100...200)
            )
        }
    }
    
    private var sampleUptimeData: [UptimeDataPoint] {
        (0..<7).map { day in
            UptimeDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -day, to: Date())!,
                uptimePercentage: Double.random(in: 98...100)
            )
        }.reversed()
    }
    
    private var sampleErrorData: [ErrorRateDataPoint] {
        (0..<24).map { hour in
            ErrorRateDataPoint(
                timestamp: Date().addingTimeInterval(-Double(24 - hour) * 3600),
                errorRate: Double.random(in: 0...0.02)
            )
        }
    }
}

// MARK: - Time Range
enum TimeRange: String, CaseIterable {
    case hour = "1H"
    case day = "24H"
    case week = "7D"
    case month = "30D"
    
    var label: String { rawValue }
}

#Preview {
    NavigationStack {
        EndpointDetailScreen(endpointId: "test-id")
    }
    .environmentObject(AppRouter())
}
