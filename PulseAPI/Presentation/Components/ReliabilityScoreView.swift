//
//  ReliabilityScoreView.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct ReliabilityScoreView: View {
    let score: Double
    let trend: TrendDirection
    var size: CGFloat = 120
    var showLabel: Bool = true
    
    @State private var animatedScore: Double = 0
    
    enum TrendDirection: String {
        case improving
        case stable
        case declining
        
        var icon: String {
            switch self {
            case .improving: return "arrow.up.right"
            case .stable: return "arrow.right"
            case .declining: return "arrow.down.right"
            }
        }
        
        var color: Color {
            switch self {
            case .improving: return .green
            case .stable: return .secondary
            case .declining: return .red
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(lineWidth: size * 0.1)
                    .foregroundStyle(.quaternary)
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(
                        scoreGradient,
                        style: StrokeStyle(
                            lineWidth: size * 0.1,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0), value: animatedScore)
                
                // Score text
                VStack(spacing: 2) {
                    Text("\(Int(animatedScore))")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    
                    HStack(spacing: 2) {
                        Image(systemName: trend.icon)
                            .font(.caption2)
                        Text(trend.rawValue.capitalized)
                            .font(.caption2)
                    }
                    .foregroundStyle(trend.color)
                }
            }
            .frame(width: size, height: size)
            
            if showLabel {
                Text("Reliability Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0).delay(0.2)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(duration: 0.5)) {
                animatedScore = newValue
            }
        }
    }
    
    private var scoreGradient: AngularGradient {
        let color = scoreColor
        return AngularGradient(
            colors: [color.opacity(0.5), color],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360 * (animatedScore / 100))
        )
    }
    
    private var scoreColor: Color {
        switch animatedScore {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Compact Version
struct ReliabilityScoreCompact: View {
    let score: Double
    let trend: ReliabilityScoreView.TrendDirection
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .foregroundStyle(.quaternary)
                
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(score))")
                    .font(.caption2.bold())
            }
            .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Reliability")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 2) {
                    Image(systemName: trend.icon)
                        .font(.caption2)
                    Text(trend.rawValue.capitalized)
                        .font(.caption2)
                }
                .foregroundStyle(trend.color)
            }
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
}

#Preview("Full") {
    VStack(spacing: 40) {
        ReliabilityScoreView(score: 92, trend: .improving)
        ReliabilityScoreView(score: 75, trend: .stable, size: 80)
        ReliabilityScoreView(score: 45, trend: .declining, size: 60)
    }
    .padding()
}

#Preview("Compact") {
    VStack(spacing: 20) {
        ReliabilityScoreCompact(score: 92, trend: .improving)
        ReliabilityScoreCompact(score: 65, trend: .declining)
    }
    .padding()
}
