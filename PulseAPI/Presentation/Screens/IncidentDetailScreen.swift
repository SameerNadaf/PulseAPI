//
//  IncidentDetailScreen.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import SwiftUI

struct IncidentDetailScreen: View {
    let incidentId: String
    
    // TODO: Replace with ViewModel in Phase 2
    @State private var incident = IncidentDetail.sample
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Severity Banner
                SeverityBanner(severity: incident.severity, status: incident.status)
                    .padding(.horizontal)
                
                // Incident Info Card
                IncidentInfoCard(incident: incident)
                    .padding(.horizontal)
                
                // Timeline Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Timeline")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(incident.timeline) { entry in
                        TimelineEntryView(entry: entry)
                            .padding(.horizontal)
                    }
                }
                
                // Affected Endpoint
                VStack(alignment: .leading, spacing: 12) {
                    Text("Affected Endpoint")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    EndpointRowCard(
                        name: incident.endpointName,
                        url: incident.endpointUrl,
                        status: .degraded,
                        latency: 450
                    )
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Incident")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if incident.status != .resolved {
                        Button {
                            // Mark resolved
                        } label: {
                            Label("Mark Resolved", systemImage: "checkmark.circle")
                        }
                        
                        Button {
                            // Update status
                        } label: {
                            Label("Update Status", systemImage: "pencil")
                        }
                    }
                    
                    Button {
                        // Share
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

// MARK: - Severity Banner
struct SeverityBanner: View {
    let severity: IncidentSeverity
    let status: IncidentStatus
    
    private var backgroundColor: Color {
        switch severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            
            Text(severity.displayName.uppercased())
                .fontWeight(.bold)
            
            Spacer()
            
            Text(status.displayName)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Incident Info Card
struct IncidentInfoCard: View {
    let incident: IncidentDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(incident.title)
                .font(.title2.bold())
            
            if let description = incident.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack {
                InfoItem(label: "Started", value: incident.startedAt.relativeTimeString)
                Spacer()
                InfoItem(label: "Duration", value: incident.durationString)
                Spacer()
                InfoItem(label: "Type", value: incident.type.displayName)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Info Item
struct InfoItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

// MARK: - Timeline Entry View
struct TimelineEntryView: View {
    let entry: TimelineEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(entry.status.isActive ? Color.orange : Color.green)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2, height: 40)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.status.displayName)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(entry.timestamp.shortTimeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(entry.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Timeline Entry Model
struct TimelineEntry: Identifiable {
    let id: String
    let status: IncidentStatus
    let message: String
    let timestamp: Date
}

// MARK: - Incident Detail Model
struct IncidentDetail {
    let id: String
    let title: String
    let description: String?
    let type: IncidentType
    let severity: IncidentSeverity
    let status: IncidentStatus
    let startedAt: Date
    let resolvedAt: Date?
    let endpointName: String
    let endpointUrl: String
    let timeline: [TimelineEntry]
    
    var durationString: String {
        let duration = (resolvedAt ?? Date()).timeIntervalSince(startedAt)
        return duration.durationString
    }
    
    static let sample = IncidentDetail(
        id: "1",
        title: "Latency Spike Detected",
        description: "Response times have increased significantly above the baseline. Average latency is now 450ms compared to the baseline of 120ms.",
        type: .latencySpike,
        severity: .major,
        status: .investigating,
        startedAt: Date().addingTimeInterval(-3600),
        resolvedAt: nil,
        endpointName: "Payment Service",
        endpointUrl: "payments.example.com/api/charge",
        timeline: [
            TimelineEntry(id: "1", status: .active, message: "Incident detected automatically by monitoring system", timestamp: Date().addingTimeInterval(-3600)),
            TimelineEntry(id: "2", status: .investigating, message: "Team is investigating the root cause", timestamp: Date().addingTimeInterval(-3000)),
        ]
    )
}

#Preview {
    NavigationStack {
        IncidentDetailScreen(incidentId: "test")
    }
}
