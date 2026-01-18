//
//  ErrorRateChartView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

struct ErrorRateDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let errorRate: Double // 0.0 to 1.0
}

struct ErrorRateChartView: View {
    let dataPoints: [ErrorRateDataPoint]
    var height: CGFloat = 160
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Error Rate", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                
                Spacer()
                
                if let current = dataPoints.last?.errorRate {
                    Text(String(format: "%.1f%%", current * 100))
                        .font(.subheadline)
                        .foregroundStyle(current > 0.05 ? .red : .secondary)
                }
            }
            
            // Chart
            if dataPoints.isEmpty {
                emptyState
            } else {
                Chart(dataPoints) { point in
                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Error Rate", point.errorRate * 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaGradient)
                    
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Error Rate", point.errorRate * 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .frame(height: height)
                .chartYScale(domain: 0...max(maxErrorRate * 100, 10))
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let pct = value.as(Double.self) {
                                Text("\(Int(pct))%")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                        AxisValueLabel(format: .dateTime.hour())
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [.red.opacity(0.4), .red.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var maxErrorRate: Double {
        dataPoints.map(\.errorRate).max() ?? 0.1
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
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
    let sampleData = (0..<24).map { hour in
        ErrorRateDataPoint(
            timestamp: Date().addingTimeInterval(-Double(24 - hour) * 3600),
            errorRate: Double.random(in: 0...0.08)
        )
    }
    
    return ErrorRateChartView(dataPoints: sampleData)
        .padding()
}
