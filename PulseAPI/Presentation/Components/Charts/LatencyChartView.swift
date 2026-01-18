//
//  LatencyChartView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI
import Charts

struct LatencyChartView: View {
    let dataPoints: [LatencyDataPoint]
    let baseline: Double?
    var height: CGFloat = 200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Response Time", systemImage: "timer")
                    .font(.headline)
                
                Spacer()
                
                if let avg = averageLatency {
                    Text("\(Int(avg))ms avg")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Chart
            if dataPoints.isEmpty {
                emptyState
            } else {
                Chart {
                    ForEach(dataPoints) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Latency", point.latencyMs)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(latencyGradient)
                        
                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Latency", point.latencyMs)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(areaGradient)
                    }
                    
                    // Baseline reference line
                    if let baseline = baseline {
                        RuleMark(y: .value("Baseline", baseline))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .foregroundStyle(.secondary)
                            .annotation(position: .top, alignment: .leading) {
                                Text("Baseline")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
                .frame(height: height)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let ms = value.as(Double.self) {
                                Text("\(Int(ms))ms")
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
    
    private var latencyGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .cyan],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var averageLatency: Double? {
        guard !dataPoints.isEmpty else { return nil }
        return dataPoints.reduce(0) { $0 + $1.latencyMs } / Double(dataPoints.count)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
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
        LatencyDataPoint(
            timestamp: Date().addingTimeInterval(-Double(24 - hour) * 3600),
            latencyMs: Double.random(in: 100...300)
        )
    }
    
    LatencyChartView(dataPoints: sampleData, baseline: 150)
        .padding()
}
