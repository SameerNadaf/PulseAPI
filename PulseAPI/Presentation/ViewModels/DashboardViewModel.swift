//
//  DashboardViewModel.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var dashboard: DashboardData?
    
    // Computed properties for UI
    var overallHealth: Int { dashboard?.overallHealth ?? 0 }
    var endpointCount: Int { dashboard?.endpointCount ?? 0 }
    var activeIncidents: Int { dashboard?.activeIncidentCount ?? 0 }
    var healthyCount: Int { dashboard?.healthyCount ?? 0 }
    var degradedCount: Int { dashboard?.degradedCount ?? 0 }
    var downCount: Int { dashboard?.downCount ?? 0 }
    var endpoints: [DashboardEndpoint] { dashboard?.endpoints ?? [] }
    var recentIncidents: [Incident] { dashboard?.recentIncidents ?? [] }
    
    // MARK: - Dependencies
    private let repository: DashboardRepositoryProtocol
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(repository: DashboardRepositoryProtocol = DashboardRepository()) {
        self.repository = repository
    }
    
    deinit {
        refreshTask?.cancel()
    }
    
    // MARK: - Actions
    func loadDashboard() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            dashboard = try await repository.getDashboard()
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadDashboard()
    }
    
    func startAutoRefresh(interval: TimeInterval = 30) {
        stopAutoRefresh()
        
        refreshTask = Task {
            while !Task.isCancelled {
                await loadDashboard()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
    
    // MARK: - Error Handling
    func dismissError() {
        error = nil
    }
}

// MARK: - Preview Helper
extension DashboardViewModel {
    static var preview: DashboardViewModel {
        let vm = DashboardViewModel()
        vm.dashboard = DashboardData(
            overallHealth: 98,
            endpointCount: 5,
            healthyCount: 4,
            degradedCount: 1,
            downCount: 0,
            activeIncidentCount: 1,
            endpoints: [
                DashboardEndpoint(id: "1", name: "User API", health: nil),
                DashboardEndpoint(id: "2", name: "Payment Service", health: nil),
            ],
            recentIncidents: []
        )
        return vm
    }
}
