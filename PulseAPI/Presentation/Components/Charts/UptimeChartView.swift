//
//  UptimeChartView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

struct UptimeDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let uptimePercentage: Double
}

struct UptimeChartView: View {
    let dataPoints: [UptimeDataPoint]
    var height: CGFloat = 160
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Uptime", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                
                Spacer()
                
                if let avg = averageUptime {
                    Text(String(format: "%.1f%% avg", avg))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Chart
            if dataPoints.isEmpty {
                emptyState
            } else {
                Chart(dataPoints) { point in
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Uptime", point.uptimePercentage)
                    )
                    .foregroundStyle(barColor(for: point.uptimePercentage))
                    .cornerRadius(4)
                }
                .frame(height: height)
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 50, 100]) { value in
                        AxisValueLabel {
                            if let pct = value.as(Double.self) {
                                Text("\(Int(pct))%")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func barColor(for value: Double) -> Color {
        switch value {
        case 99...100: return .green
        case 95..<99: return .yellow
        case 90..<95: return .orange
        default: return .red
        }
    }
    
    private var averageUptime: Double? {
        guard !dataPoints.isEmpty else { return nil }
        return dataPoints.reduce(0) { $0 + $1.uptimePercentage } / Double(dataPoints.count)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("No data yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleData = (0..<7).map { day in
        UptimeDataPoint(
            date: Calendar.current.date(byAdding: .day, value: -day, to: Date())!,
            uptimePercentage: Double.random(in: 94...100)
        )
    }.reversed()
    
    return UptimeChartView(dataPoints: Array(sampleData))
        .padding()
}
