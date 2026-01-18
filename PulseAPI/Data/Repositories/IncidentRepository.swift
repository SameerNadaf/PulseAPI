//
//  IncidentRepository.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

protocol IncidentRepositoryProtocol {
    func getIncidents(status: IncidentStatus?) async throws -> [Incident]
    func getIncident(id: String) async throws -> (Incident, [IncidentTimelineEntry])
    func updateStatus(incidentId: String, status: IncidentStatus, message: String) async throws
    func getStats() async throws -> IncidentStatsDTO
}

final class IncidentRepository: IncidentRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getIncidents(status: IncidentStatus? = nil) async throws -> [Incident] {
        let response = try await apiClient.request(
            IncidentsAPI.list(status: status?.rawValue),
            expecting: APIResponse<[IncidentDTO]>.self
        )
        
        guard let data = response.data else {
            return []
        }
        
        return data.map { $0.toDomain() }
    }
    
    func getIncident(id: String) async throws -> (Incident, [IncidentTimelineEntry]) {
        let response = try await apiClient.request(
            IncidentsAPI.get(id: id),
            expecting: APIResponse<IncidentWithTimelineResponse>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.notFound
        }
        
        let incident = data.incident.toDomain()
        let timeline = data.timeline.map { $0.toDomain() }
        
        return (incident, timeline)
    }
    
    func updateStatus(incidentId: String, status: IncidentStatus, message: String) async throws {
        _ = try await apiClient.request(
            IncidentsAPI.updateStatus(id: incidentId, status: status.rawValue, message: message),
            expecting: APIResponse<EmptyResponse>.self
        )
    }
    
    func getStats() async throws -> IncidentStatsDTO {
        let response = try await apiClient.request(
            IncidentsAPI.stats,
            expecting: APIResponse<IncidentStatsDTO>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("No stats data")
        }
        
        return data
    }
}

// MARK: - DTO to Domain Mapping
extension IncidentDTO {
    func toDomain() -> Incident {
        let incidentType = IncidentType(rawValue: type) ?? .latencySpike
        let incidentSeverity = IncidentSeverity(rawValue: severity) ?? .minor
        let incidentStatus = IncidentStatus(rawValue: status) ?? .active
        
        return Incident(
            id: id,
            endpointId: endpointId,
            type: incidentType,
            severity: incidentSeverity,
            status: incidentStatus,
            startedAt: ISO8601DateFormatter().date(from: startedAt) ?? Date(),
            resolvedAt: resolvedAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            title: title,
            description: description,
            affectedRegions: parseRegions(affectedRegions),
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date()
        )
    }
    
    private func parseRegions(_ json: String?) -> [String] {
        guard let json = json,
              let data = json.data(using: .utf8),
              let regions = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return regions
    }
}

extension TimelineEntryDTO {
    func toDomain() -> IncidentTimelineEntry {
        let entryStatus = IncidentStatus(rawValue: status) ?? .active
        
        return IncidentTimelineEntry(
            id: id,
            incidentId: incidentId,
            status: entryStatus,
            message: message,
            timestamp: ISO8601DateFormatter().date(from: timestamp) ?? Date()
        )
    }
}
