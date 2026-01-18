//
//  EndpointDetailViewModel.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

@MainActor
final class EndpointDetailViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var endpoint: Endpoint?
    @Published private(set) var healthSummary: EndpointHealthSummary?
    @Published private(set) var probeHistory: [ProbeResultDTO] = []
    @Published private(set) var probeStats: ProbeStatsDTO?
    
    // MARK: - Computed Properties
    var name: String { endpoint?.name ?? "Loading..." }
    var url: String { endpoint?.url ?? "" }
    var status: EndpointStatus { healthSummary?.status ?? .unknown }
    var latency: Double? { healthSummary?.currentLatencyMs }
    var uptimePercentage: Double { healthSummary?.uptimePercentage ?? 0 }
    var errorRate: Double { healthSummary?.errorRate ?? 0 }
    var reliabilityScore: Double { healthSummary?.reliabilityScore ?? 0 }
    
    // Chart data points
    var latencyDataPoints: [Double] {
        probeHistory
            .compactMap { $0.latencyMs }
            .suffix(24) // Last 24 points
            .reversed()
            .map { $0 }
    }
    
    var errorRateDataPoints: [Double] {
        // Calculate error rate per time bucket
        let grouped = Dictionary(grouping: probeHistory.suffix(24)) { _ in true }
        return grouped.values.map { probes in
            let errors = probes.filter { $0.status != "success" }.count
            return Double(errors) / Double(max(probes.count, 1))
        }
    }
    
    // MARK: - Dependencies
    private let endpointId: String
    private let endpointRepository: EndpointRepositoryProtocol
    private let apiClient: APIClient
    
    // MARK: - Initialization
    init(
        endpointId: String,
        endpointRepository: EndpointRepositoryProtocol = EndpointRepository(),
        apiClient: APIClient = .shared
    ) {
        self.endpointId = endpointId
        self.endpointRepository = endpointRepository
        self.apiClient = apiClient
    }
    
    // MARK: - Actions
    func loadEndpoint() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            // Load endpoint details
            endpoint = try await endpointRepository.getEndpoint(id: endpointId)
            
            // Load health summary
            healthSummary = try await endpointRepository.getHealthSummary(endpointId: endpointId)
            
            // Load probe history
            let historyResponse = try await apiClient.request(
                ProbesAPI.history(endpointId: endpointId, hours: 24),
                expecting: APIResponse<[ProbeResultDTO]>.self
            )
            probeHistory = historyResponse.data ?? []
            
            // Load probe stats
            let statsResponse = try await apiClient.request(
                ProbesAPI.stats(endpointId: endpointId, hours: 24),
                expecting: APIResponse<ProbeStatsDTO>.self
            )
            probeStats = statsResponse.data
            
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadEndpoint()
    }
    
    func toggleActive() async {
        guard let endpoint = endpoint else { return }
        
        let request = UpdateEndpointRequest(
            name: nil, url: nil, method: nil,
            probeIntervalMinutes: nil, timeoutSeconds: nil,
            expectedStatusCodes: nil, isActive: !endpoint.isActive
        )
        
        do {
            self.endpoint = try await endpointRepository.updateEndpoint(id: endpointId, request)
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
    }
    
    func deleteEndpoint() async -> Bool {
        do {
            try await endpointRepository.deleteEndpoint(id: endpointId)
            return true
        } catch let networkError as NetworkError {
            error = networkError
            return false
        } catch {
            self.error = .unknown(error)
            return false
        }
    }
    
    // MARK: - Error Handling
    func dismissError() {
        error = nil
    }
}
