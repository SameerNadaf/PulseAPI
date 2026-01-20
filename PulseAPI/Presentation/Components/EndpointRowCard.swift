//
//  EndpointRowCard.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

struct EndpointRowCard: View {
    let name: String
    let url: String
    let status: EndpointStatus
    let latency: Double?
    var showSparkline: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)
            
            // Endpoint Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                
                Text(url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Sparkline (mini chart)
            if showSparkline {
                SparklineView(data: generateSparklineData())
                    .frame(width: 60, height: 24)
            }
            
            // Latency
            VStack(alignment: .trailing, spacing: 2) {
                Text(latency.map { "\(Int($0))ms" } ?? "--")
                    .font(.subheadline.bold())
                    .foregroundStyle(latencyColor)
                
                Text(status.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var latencyColor: Color {
        guard let lat = latency else { return .secondary }
        switch lat {
        case 0..<100: return .green
        case 100..<300: return .primary
        case 300..<500: return .orange
        default: return .red
        }
    }
    
    private func generateSparklineData() -> [Double] {
        let base = latency ?? 100
        return (0..<10).map { _ in
            Double.random(in: max(0, base - 50)...(base + 50))
        }
    }
}

// MARK: - Sparkline View
struct SparklineView: View {
    let data: [Double]
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(.blue.opacity(0.8))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
    }
}

// MARK: - EndpointStatus Color Extension
extension EndpointStatus {
    var color: Color {
        switch self {
        case .healthy: return .green
        case .degraded: return .orange
        case .down: return .red
        case .unknown: return .gray
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        EndpointRowCard(name: "Payment API", url: "api.payments.com/v1/charge", status: .healthy, latency: 125)
        EndpointRowCard(name: "User Service", url: "users.example.com/api", status: .degraded, latency: 450)
        EndpointRowCard(name: "Search API", url: "search.example.com", status: .down, latency: 0)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
