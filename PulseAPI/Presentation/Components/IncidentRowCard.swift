//
//  IncidentRowCard.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct IncidentRowCard: View {
    let title: String
    let endpoint: String
    let severity: IncidentSeverity
    let startedAt: Date
    var status: IncidentStatus = .active
    
    var body: some View {
        HStack(spacing: 12) {
            // Severity Indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(severity.color)
                .frame(width: 4, height: 50)
            
            // Incident Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    
                    Spacer()
                    
                    StatusBadge(status: status)
                }
                
                HStack(spacing: 8) {
                    Label(endpoint, systemImage: "server.rack")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(startedAt.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: IncidentStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.backgroundColor)
            .foregroundStyle(status.foregroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - IncidentSeverity Color Extension
extension IncidentSeverity {
    var color: Color {
        switch self {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        }
    }
}

// MARK: - IncidentStatus Color Extension
extension IncidentStatus {
    var backgroundColor: Color {
        switch self {
        case .active: return .red.opacity(0.15)
        case .investigating: return .orange.opacity(0.15)
        case .identified: return .yellow.opacity(0.15)
        case .monitoring: return .blue.opacity(0.15)
        case .resolved: return .green.opacity(0.15)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .active: return .red
        case .investigating: return .orange
        case .identified: return .yellow
        case .monitoring: return .blue
        case .resolved: return .green
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        IncidentRowCard(
            title: "Latency Spike Detected",
            endpoint: "Payment API",
            severity: .major,
            startedAt: Date().addingTimeInterval(-3600),
            status: .investigating
        )
        
        IncidentRowCard(
            title: "Complete Outage",
            endpoint: "Search Service",
            severity: .critical,
            startedAt: Date().addingTimeInterval(-7200),
            status: .active
        )
        
        IncidentRowCard(
            title: "Timeout Issues",
            endpoint: "Notifications",
            severity: .minor,
            startedAt: Date().addingTimeInterval(-86400),
            status: .resolved
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
