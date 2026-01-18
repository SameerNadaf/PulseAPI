//
//  APIResponses.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - Generic API Response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: String?
    let meta: ResponseMeta?
}

struct ResponseMeta: Decodable {
    let total: Int?
    let page: Int?
    let limit: Int?
}

// MARK: - Dashboard Response
struct DashboardResponse: Decodable {
    let overallHealth: Int
    let endpointCount: Int
    let healthyCount: Int
    let degradedCount: Int
    let downCount: Int
    let activeIncidentCount: Int
    let endpoints: [EndpointWithHealth]
    let recentIncidents: [IncidentDTO]
}

struct EndpointWithHealth: Decodable, Identifiable {
    let endpoint: EndpointBasicDTO
    let health: HealthSummaryDTO?
    
    var id: String { endpoint.id }
}

struct EndpointBasicDTO: Decodable {
    let id: String
    let name: String
}

struct HealthSummaryDTO: Decodable {
    let endpointId: String
    let status: String
    let reliabilityScore: Double
    let currentLatencyMs: Double?
    let baselineLatencyMs: Double?
    let errorRate: Double
    let lastProbeAt: String?
    let lastIncidentAt: String?
    let uptimePercentage: Double
}

// MARK: - Endpoint Response
struct EndpointDTO: Decodable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let url: String
    let method: String
    let headers: String?
    let body: String?
    let probeIntervalMinutes: Int
    let timeoutSeconds: Int
    let expectedStatusCodes: String
    let isActive: Int
    let createdAt: String
    let updatedAt: String
}

// MARK: - Incident Response
struct IncidentDTO: Decodable, Identifiable {
    let id: String
    let endpointId: String
    let type: String
    let severity: String
    let status: String
    let startedAt: String
    let resolvedAt: String?
    let title: String
    let description: String?
    let affectedRegions: String?
    let createdAt: String
    let updatedAt: String
}

struct IncidentWithTimelineResponse: Decodable {
    let incident: IncidentDTO
    let timeline: [TimelineEntryDTO]
}

struct TimelineEntryDTO: Decodable, Identifiable {
    let id: String
    let incidentId: String
    let status: String
    let message: String
    let timestamp: String
}

// MARK: - Probe Response
struct ProbeResultDTO: Decodable, Identifiable {
    let id: String
    let endpointId: String
    let timestamp: String
    let status: String
    let latencyMs: Double?
    let statusCode: Int?
    let errorMessage: String?
    let region: String
}

struct ProbeStatsDTO: Decodable {
    let totalProbes: Int
    let successCount: Int
    let errorCount: Int
    let timeoutCount: Int
    let avgLatencyMs: Double?
    let minLatencyMs: Double?
    let maxLatencyMs: Double?
}

// MARK: - Incident Stats Response
struct IncidentStatsDTO: Decodable {
    let total: Int
    let active: Int
    let resolved: Int
    let critical: Int
    let major: Int
    let minor: Int
}

// MARK: - User Response
struct UserDTO: Decodable {
    let id: String
    let email: String
    let subscriptionStatus: String
    let subscriptionExpiresAt: String?
    let createdAt: String
    let endpointCount: Int?
}
