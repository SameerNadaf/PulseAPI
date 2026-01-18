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
    
    // TODO: Replace with ViewModel in Phase 2
    @State private var selectedTimeRange: TimeRange = .day
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status Header
                EndpointStatusHeader(
                    status: .healthy,
                    latency: 125,
                    uptime: 99.8
                )
                .padding(.horizontal)
                
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Latency Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Latency")
                        .font(.headline)
                    
                    LatencyChartView(dataPoints: LatencyDataPoint.sampleData)
                        .frame(height: 200)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Error Rate Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Error Rate")
                        .font(.headline)
                    
                    ErrorRateChartView()
                        .frame(height: 150)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Statistics Grid
                StatisticsGrid()
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
                
                Spacer(minLength: 20)
            }
            .padding(.top)
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
}

// MARK: - Time Range
enum TimeRange: String, CaseIterable {
    case hour = "1H"
    case day = "24H"
    case week = "7D"
    case month = "30D"
    
    var label: String { rawValue }
}

// MARK: - Status Header
struct EndpointStatusHeader: View {
    let status: EndpointStatus
    let latency: Double
    let uptime: Double
    
    var body: some View {
        HStack(spacing: 24) {
            // Status Indicator
            VStack(spacing: 8) {
                Circle()
                    .fill(status.color)
                    .frame(width: 16, height: 16)
                Text(status.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Current Latency
            VStack(spacing: 4) {
                Text("\(Int(latency))ms")
                    .font(.title2.bold())
                Text("Latency")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Uptime
            VStack(spacing: 4) {
                Text(String(format: "%.1f%%", uptime))
                    .font(.title2.bold())
                    .foregroundStyle(.green)
                Text("Uptime")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Latency Chart View
struct LatencyChartView: View {
    let dataPoints: [LatencyDataPoint]
    
    var body: some View {
        Chart(dataPoints) { point in
            LineMark(
                x: .value("Time", point.timestamp),
                y: .value("Latency", point.latencyMs)
            )
            .foregroundStyle(.blue)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Time", point.timestamp),
                y: .value("Latency", point.latencyMs)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
            
            if point.isAnomaly {
                PointMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Latency", point.latencyMs)
                )
                .foregroundStyle(.red)
                .symbolSize(100)
            }
        }
        .chartYAxisLabel("ms")
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
    }
}

// MARK: - Error Rate Chart View
struct ErrorRateChartView: View {
    var body: some View {
        Chart {
            ForEach(0..<7, id: \.self) { day in
                BarMark(
                    x: .value("Day", Calendar.current.shortWeekdaySymbols[day]),
                    y: .value("Errors", Double.random(in: 0...5))
                )
                .foregroundStyle(.blue.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .chartYAxisLabel("%")
    }
}

// MARK: - Statistics Grid
struct StatisticsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(title: "Avg Latency", value: "125ms", icon: "clock.fill", color: .blue)
            StatCard(title: "P95 Latency", value: "280ms", icon: "chart.line.uptrend.xyaxis", color: .orange)
            StatCard(title: "Success Rate", value: "99.8%", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Total Requests", value: "12.4K", icon: "arrow.up.arrow.down", color: .purple)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Sample Data Extension
extension LatencyDataPoint {
    static var sampleData: [LatencyDataPoint] {
        (0..<24).map { hour in
            LatencyDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(-hour * 3600)),
                latencyMs: Double.random(in: 80...200),
                isAnomaly: hour == 12
            )
        }.reversed()
    }
}

#Preview {
    NavigationStack {
        EndpointDetailScreen(endpointId: "test-id")
    }
    .environmentObject(AppRouter())
}
