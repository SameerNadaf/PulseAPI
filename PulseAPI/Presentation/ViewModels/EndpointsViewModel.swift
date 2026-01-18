//
//  EndpointsViewModel.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

@MainActor
final class EndpointsViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var endpoints: [Endpoint] = []
    @Published var searchText = ""
    
    // Filtered endpoints
    var filteredEndpoints: [Endpoint] {
        if searchText.isEmpty {
            return endpoints
        }
        return endpoints.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.url.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Dependencies
    private let repository: EndpointRepositoryProtocol
    
    // MARK: - Initialization
    init(repository: EndpointRepositoryProtocol = EndpointRepository()) {
        self.repository = repository
    }
    
    // MARK: - Actions
    func loadEndpoints() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            endpoints = try await repository.getEndpoints()
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadEndpoints()
    }
    
    func deleteEndpoint(_ endpoint: Endpoint) async {
        do {
            try await repository.deleteEndpoint(id: endpoint.id)
            endpoints.removeAll { $0.id == endpoint.id }
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
    }
    
    func toggleEndpointActive(_ endpoint: Endpoint) async {
        let request = UpdateEndpointRequest(
            name: nil, url: nil, method: nil,
            probeIntervalMinutes: nil, timeoutSeconds: nil,
            expectedStatusCodes: nil, isActive: !endpoint.isActive
        )
        
        do {
            let updated = try await repository.updateEndpoint(id: endpoint.id, request)
            if let index = endpoints.firstIndex(where: { $0.id == endpoint.id }) {
                endpoints[index] = updated
            }
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
    }
    
    // MARK: - Error Handling
    func dismissError() {
        error = nil
    }
}

// MARK: - Preview Helper
extension EndpointsViewModel {
    static var preview: EndpointsViewModel {
        let vm = EndpointsViewModel()
        vm.endpoints = [
            Endpoint(
                id: "1", name: "User API", url: "api.example.com/users",
                method: .get, headers: nil, body: nil,
                probeIntervalMinutes: 5, timeoutSeconds: 10,
                expectedStatusCodes: [200], isActive: true,
                createdAt: Date(), updatedAt: Date()
            ),
            Endpoint(
                id: "2", name: "Payment Service", url: "payments.example.com",
                method: .post, headers: nil, body: nil,
                probeIntervalMinutes: 1, timeoutSeconds: 30,
                expectedStatusCodes: [200, 201], isActive: true,
                createdAt: Date(), updatedAt: Date()
            ),
        ]
        return vm
    }
}
