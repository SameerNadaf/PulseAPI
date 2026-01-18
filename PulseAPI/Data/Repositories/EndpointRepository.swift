//
//  EndpointRepository.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

protocol EndpointRepositoryProtocol {
    func getEndpoints() async throws -> [Endpoint]
    func getEndpoint(id: String) async throws -> Endpoint
    func getHealthSummary(endpointId: String) async throws -> EndpointHealthSummary
    func createEndpoint(_ request: CreateEndpointRequest) async throws -> Endpoint
    func updateEndpoint(id: String, _ request: UpdateEndpointRequest) async throws -> Endpoint
    func deleteEndpoint(id: String) async throws
}

final class EndpointRepository: EndpointRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getEndpoints() async throws -> [Endpoint] {
        let response = try await apiClient.request(
            EndpointsAPI.list,
            expecting: APIResponse<[EndpointDTO]>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("No data in response")
        }
        
        return data.map { $0.toDomain() }
    }
    
    func getEndpoint(id: String) async throws -> Endpoint {
        let response = try await apiClient.request(
            EndpointsAPI.get(id: id),
            expecting: APIResponse<EndpointDTO>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.notFound
        }
        
        return data.toDomain()
    }
    
    func getHealthSummary(endpointId: String) async throws -> EndpointHealthSummary {
        let response = try await apiClient.request(
            EndpointsAPI.health(id: endpointId),
            expecting: APIResponse<HealthSummaryDTO>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("No health data")
        }
        
        return data.toDomain()
    }
    
    func createEndpoint(_ request: CreateEndpointRequest) async throws -> Endpoint {
        let response = try await apiClient.request(
            EndpointsAPI.create(request),
            expecting: APIResponse<EndpointDTO>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("Failed to create endpoint")
        }
        
        return data.toDomain()
    }
    
    func updateEndpoint(id: String, _ request: UpdateEndpointRequest) async throws -> Endpoint {
        let response = try await apiClient.request(
            EndpointsAPI.update(id: id, request),
            expecting: APIResponse<EndpointDTO>.self
        )
        
        guard let data = response.data else {
            throw NetworkError.decodingFailed("Failed to update endpoint")
        }
        
        return data.toDomain()
    }
    
    func deleteEndpoint(id: String) async throws {
        _ = try await apiClient.request(
            EndpointsAPI.delete(id: id),
            expecting: APIResponse<EmptyResponse>.self
        )
    }
}

// MARK: - Empty Response
struct EmptyResponse: Decodable {
    let deleted: Bool?
}

// MARK: - DTO to Domain Mapping
extension EndpointDTO {
    func toDomain() -> Endpoint {
        let httpMethod = HTTPMethod(rawValue: method.uppercased()) ?? .get
        let statusCodes = parseStatusCodes(expectedStatusCodes)
        
        return Endpoint(
            id: id,
            name: name,
            url: url,
            method: httpMethod,
            headers: parseHeaders(headers),
            body: body,
            probeIntervalMinutes: probeIntervalMinutes,
            timeoutSeconds: timeoutSeconds,
            expectedStatusCodes: statusCodes,
            isActive: isActive == 1,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date()
        )
    }
    
    private func parseStatusCodes(_ json: String) -> [Int] {
        guard let data = json.data(using: .utf8),
              let codes = try? JSONDecoder().decode([Int].self, from: data) else {
            return [200]
        }
        return codes
    }
    
    private func parseHeaders(_ json: String?) -> [String: String]? {
        guard let json = json,
              let data = json.data(using: .utf8),
              let headers = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        return headers
    }
}

extension HealthSummaryDTO {
    func toDomain() -> EndpointHealthSummary {
        let endpointStatus = EndpointStatus(rawValue: status) ?? .unknown
        
        return EndpointHealthSummary(
            endpointId: endpointId,
            status: endpointStatus,
            reliabilityScore: reliabilityScore,
            currentLatencyMs: currentLatencyMs,
            baselineLatencyMs: baselineLatencyMs,
            errorRate: errorRate,
            lastProbeAt: lastProbeAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            lastIncidentAt: lastIncidentAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            uptimePercentage: uptimePercentage
        )
    }
}

