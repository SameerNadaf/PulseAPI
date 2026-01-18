//
//  StatCard.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

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
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack {
        StatCard(
            title: "Avg Latency",
            value: "125ms",
            icon: "clock.fill",
            color: .blue
        )
        
        StatCard(
            title: "Success Rate",
            value: "99.9%",
            icon: "checkmark.circle.fill",
            color: .green
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
