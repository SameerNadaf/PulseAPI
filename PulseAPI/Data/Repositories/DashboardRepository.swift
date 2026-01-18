//
//  DashboardRepository.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

protocol DashboardRepositoryProtocol {
    func getDashboard() async throws -> DashboardData
}

final class DashboardRepository: DashboardRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getDashboard() async throws -> DashboardData {
        let response = try await apiClient.requestWithRetry(
            DashboardAPI.summary,
            expecting: APIResponse<DashboardResponse>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("No dashboard data")
        }
        
        return data.toDomain()
    }
}

// MARK: - Dashboard Domain Model
struct DashboardData {
    let overallHealth: Int
    let endpointCount: Int
    let healthyCount: Int
    let degradedCount: Int
    let downCount: Int
    let activeIncidentCount: Int
    let endpoints: [DashboardEndpoint]
    let recentIncidents: [Incident]
}

struct DashboardEndpoint: Identifiable {
    let id: String
    let name: String
    let health: EndpointHealthSummary?
    
    var status: EndpointStatus {
        health?.status ?? .unknown
    }
    
    var latency: Double? {
        health?.currentLatencyMs
    }
}

// MARK: - DTO to Domain Mapping
extension DashboardResponse {
    func toDomain() -> DashboardData {
        DashboardData(
            overallHealth: overallHealth,
            endpointCount: endpointCount,
            healthyCount: healthyCount,
            degradedCount: degradedCount,
            downCount: downCount,
            activeIncidentCount: activeIncidentCount,
            endpoints: endpoints.map { $0.toDomain() },
            recentIncidents: recentIncidents.map { $0.toDomain() }
        )
    }
}

extension EndpointWithHealth {
    func toDomain() -> DashboardEndpoint {
        DashboardEndpoint(
            id: endpoint.id,
            name: endpoint.name,
            health: health?.toDomain()
        )
    }
}
