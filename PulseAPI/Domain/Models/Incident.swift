//
//  Incident.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - Incident Severity
enum IncidentSeverity: String, Codable, CaseIterable {
    case minor      // Degraded performance
    case major      // Significant degradation
    case critical   // Complete outage
    
    var displayName: String {
        switch self {
        case .minor: return "Minor"
        case .major: return "Major"
        case .critical: return "Critical"
        }
    }
    
    var priority: Int {
        switch self {
        case .critical: return 3
        case .major: return 2
        case .minor: return 1
        }
    }
}

// MARK: - Incident Status
enum IncidentStatus: String, Codable {
    case active
    case investigating
    case identified
    case monitoring
    case resolved
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .investigating: return "Investigating"
        case .identified: return "Identified"
        case .monitoring: return "Monitoring"
        case .resolved: return "Resolved"
        }
    }
    
    var isActive: Bool {
        self != .resolved
    }
}

// MARK: - Incident Type
enum IncidentType: String, Codable {
    case latencySpike       // Response time significantly above baseline
    case highErrorRate      // Error rate above threshold
    case timeout            // Consistent timeouts
    case completeOutage     // All probes failing
    
    var displayName: String {
        switch self {
        case .latencySpike: return "Latency Spike"
        case .highErrorRate: return "High Error Rate"
        case .timeout: return "Timeout"
        case .completeOutage: return "Complete Outage"
        }
    }
}

// MARK: - Incident Model
struct Incident: Identifiable, Codable {
    let id: String
    let endpointId: String
    let type: IncidentType
    var severity: IncidentSeverity
    var status: IncidentStatus
    let startedAt: Date
    var resolvedAt: Date?
    var title: String
    var description: String?
    var affectedRegions: [String]?
    let createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed
    var duration: TimeInterval? {
        guard let resolved = resolvedAt else {
            return Date().timeIntervalSince(startedAt)
        }
        return resolved.timeIntervalSince(startedAt)
    }
    
    var durationString: String {
        guard let duration = duration else { return "Unknown" }
        return duration.durationString
    }
    
    var isResolved: Bool {
        status == .resolved
    }
}

// MARK: - Incident + Factory
extension Incident {
    static func create(
        endpointId: String,
        type: IncidentType,
        severity: IncidentSeverity,
        title: String,
        description: String? = nil
    ) -> Incident {
        let now = Date()
        return Incident(
            id: UUID().uuidString,
            endpointId: endpointId,
            type: type,
            severity: severity,
            status: .active,
            startedAt: now,
            resolvedAt: nil,
            title: title,
            description: description,
            affectedRegions: nil,
            createdAt: now,
            updatedAt: now
        )
    }
}

// MARK: - Incident Timeline Entry
struct IncidentTimelineEntry: Identifiable, Codable {
    let id: String
    let incidentId: String
    let status: IncidentStatus
    let message: String
    let timestamp: Date
    
    static func create(incidentId: String, status: IncidentStatus, message: String) -> IncidentTimelineEntry {
        IncidentTimelineEntry(
            id: UUID().uuidString,
            incidentId: incidentId,
            status: status,
            message: message,
            timestamp: Date()
        )
    }
}
