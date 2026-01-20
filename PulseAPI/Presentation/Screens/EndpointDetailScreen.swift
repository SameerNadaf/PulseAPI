//
//  EndpointDetailScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

// ISO8601 formatter with fractional seconds support
private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

struct EndpointDetailScreen: View {
    let endpointId: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: EndpointDetailViewModel
    
    @State private var selectedTimeRange: TimeRange = .day
    @State private var showDeleteConfirmation = false
    
    init(endpointId: String) {
        self.endpointId = endpointId
        _viewModel = StateObject(wrappedValue: EndpointDetailViewModel(endpointId: endpointId))
    }
    
    var body: some View {
        mainContent
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.loadEndpoint() }
            .confirmationDialog("Delete Endpoint", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task {
                        if await viewModel.deleteEndpoint() {
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this endpoint? This action cannot be undone.")
            }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading && viewModel.endpoint == nil {
            loadingView
        } else if let error = viewModel.error, viewModel.endpoint == nil {
            errorView(error: error)
        } else {
            contentView
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    Task { await viewModel.toggleActive() }
                } label: {
                    Label(
                        viewModel.endpoint?.isActive == true ? "Pause Monitoring" : "Resume Monitoring",
                        systemImage: viewModel.endpoint?.isActive == true ? "pause.circle" : "play.circle"
                    )
                }
                
                Divider()
                
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Reliability Score
                headerSection
                
                // Time Range Picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedTimeRange) { _, newRange in
                    Task {
                        await viewModel.loadProbeData(hours: newRange.hours)
                    }
                }
                
                // Charts Section
                chartsSection
                
                // Statistics Grid
                statsSection
                
                // Recent Incidents
                incidentsSection
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(statusText)
                        .font(.title2.bold())
                        .foregroundStyle(statusColor)
                }
                
                Text("Last checked: \(lastCheckedText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let url = viewModel.endpoint?.url {
                    Text(url)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            ReliabilityScoreView(
                score: viewModel.reliabilityScore,
                trend: .stable,
                size: 80,
                showLabel: false
            )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(spacing: 16) {
            LatencyChartView(
                dataPoints: latencyChartData,
                baseline: viewModel.probeStats?.avgLatencyMs,
                height: 200
            )
            
            UptimeChartView(
                dataPoints: uptimeChartData,
                height: 160
            )
            
            ErrorRateChartView(
                dataPoints: errorRateChartData,
                height: 160
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Avg Latency",
                value: formatLatency(viewModel.probeStats?.avgLatencyMs),
                icon: "clock.fill",
                color: .blue
            )
            StatCard(
                title: "Max Latency",
                value: formatLatency(viewModel.probeStats?.maxLatencyMs),
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            StatCard(
                title: "Success Rate",
                value: formatSuccessRate(),
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                title: "Total Probes",
                value: formatProbeCount(),
                icon: "arrow.up.arrow.down",
                color: .purple
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Incidents Section
    private var incidentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Incidents")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.probeHistory.filter({ $0.status != "success" }).isEmpty {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                    Text("No recent incidents")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            } else {
                ForEach(viewModel.probeHistory.filter { $0.status != "success" }.prefix(3), id: \.id) { probe in
                    ProbeErrorRow(probe: probe)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading endpoint...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(error: NetworkError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Failed to load endpoint")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Retry") {
                Task { await viewModel.loadEndpoint() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        switch viewModel.status {
        case .healthy: return .green
        case .degraded: return .orange
        case .down: return .red
        case .unknown: return .gray
        }
    }
    
    private var statusText: String {
        switch viewModel.status {
        case .healthy: return "Online"
        case .degraded: return "Degraded"
        case .down: return "Down"
        case .unknown: return "Unknown"
        }
    }
    
    private var lastCheckedText: String {
        guard let lastProbe = viewModel.probeHistory.first else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        if let date = isoFormatter.date(from: lastProbe.timestamp) {
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        return "Recently"
    }
    
    // MARK: - Chart Data
    private var latencyChartData: [LatencyDataPoint] {
        viewModel.probeHistory
            .compactMap { probe -> LatencyDataPoint? in
                guard let latency = probe.latencyMs,
                      let date = isoFormatter.date(from: probe.timestamp) else { return nil }
                return LatencyDataPoint(timestamp: date, latencyMs: latency)
            }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private var uptimeChartData: [UptimeDataPoint] {
        // Group probes by day and calculate uptime
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.probeHistory) { probe -> Date in
            guard let date = isoFormatter.date(from: probe.timestamp) else {
                return Date()
            }
            return calendar.startOfDay(for: date)
        }
        
        return grouped.map { (day, probes) in
            let successCount = probes.filter { $0.status == "success" }.count
            let uptime = Double(successCount) / Double(max(probes.count, 1)) * 100
            return UptimeDataPoint(date: day, uptimePercentage: uptime)
        }
        .sorted { $0.date < $1.date }
        .suffix(7)
        .map { $0 }
    }
    
    private var errorRateChartData: [ErrorRateDataPoint] {
        viewModel.probeHistory
            .compactMap { probe -> ErrorRateDataPoint? in
                guard let date = isoFormatter.date(from: probe.timestamp) else { return nil }
                let rate = probe.status == "success" ? 0.0 : 1.0
                return ErrorRateDataPoint(timestamp: date, errorRate: rate)
            }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    // MARK: - Formatters
    private func formatLatency(_ ms: Double?) -> String {
        guard let ms = ms else { return "—" }
        if ms < 1000 {
            return "\(Int(ms))ms"
        } else {
            return String(format: "%.1fs", ms / 1000)
        }
    }
    
    private func formatSuccessRate() -> String {
        guard let stats = viewModel.probeStats,
              stats.totalProbes > 0 else { return "—" }
        let rate = Double(stats.successCount) / Double(stats.totalProbes) * 100
        return String(format: "%.1f%%", rate)
    }
    
    private func formatProbeCount() -> String {
        guard let count = viewModel.probeStats?.totalProbes else { return "—" }
        if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Probe Error Row
struct ProbeErrorRow: View {
    let probe: ProbeResultDTO
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: probe.status == "timeout" ? "clock.badge.exclamationmark" : "xmark.circle.fill")
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(probe.status == "timeout" ? "Timeout" : "Error")
                    .font(.subheadline.bold())
                if let message = probe.errorMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(formatTime(probe.timestamp))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatTime(_ timestamp: String) -> String {
        guard let date = isoFormatter.date(from: timestamp) else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Time Range
enum TimeRange: String, CaseIterable {
    case hour = "1H"
    case day = "24H"
    case week = "7D"
    case month = "30D"
    
    var label: String { rawValue }
    
    var hours: Int {
        switch self {
        case .hour: return 1
        case .day: return 24
        case .week: return 168
        case .month: return 720
        }
    }
}

#Preview {
    NavigationStack {
        EndpointDetailScreen(endpointId: "test-id")
    }
    .environmentObject(AppRouter())
}
