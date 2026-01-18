//
//  IncidentsViewModel.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

@MainActor
final class IncidentsViewModel: ObservableObject {
    // MARK: - Filter
    enum Filter: String, CaseIterable {
        case active = "Active"
        case resolved = "Resolved"
        case all = "All"
        
        var status: IncidentStatus? {
            switch self {
            case .active: return nil // API handles active filter differently
            case .resolved: return .resolved
            case .all: return nil
            }
        }
    }
    
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var incidents: [Incident] = []
    @Published var selectedFilter: Filter = .active
    
    // Filtered incidents based on local filter
    var filteredIncidents: [Incident] {
        switch selectedFilter {
        case .active:
            return incidents.filter { $0.status != .resolved }
        case .resolved:
            return incidents.filter { $0.status == .resolved }
        case .all:
            return incidents
        }
    }
    
    // MARK: - Dependencies
    private let repository: IncidentRepositoryProtocol
    
    // MARK: - Initialization
    init(repository: IncidentRepositoryProtocol = IncidentRepository()) {
        self.repository = repository
    }
    
    // MARK: - Actions
    func loadIncidents() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            incidents = try await repository.getIncidents(status: nil)
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadIncidents()
    }
    
    func resolveIncident(_ incident: Incident, message: String = "Manually resolved") async {
        do {
            try await repository.updateStatus(
                incidentId: incident.id,
                status: .resolved,
                message: message
            )
            // Update local state
            if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
                var updated = incidents[index]
                updated = Incident(
                    id: updated.id,
                    endpointId: updated.endpointId,
                    type: updated.type,
                    severity: updated.severity,
                    status: .resolved,
                    startedAt: updated.startedAt,
                    resolvedAt: Date(),
                    title: updated.title,
                    description: updated.description,
                    affectedRegions: updated.affectedRegions,
                    createdAt: updated.createdAt,
                    updatedAt: Date()
                )
                incidents[index] = updated
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
extension IncidentsViewModel {
    static var preview: IncidentsViewModel {
        let vm = IncidentsViewModel()
        vm.incidents = [
            Incident(
                id: "1", endpointId: "ep1",
                type: .latencySpike, severity: .major, status: .investigating,
                startedAt: Date().addingTimeInterval(-3600), resolvedAt: nil,
                title: "Latency Spike Detected", description: nil,
                affectedRegions: [], createdAt: Date(), updatedAt: Date()
            ),
            Incident(
                id: "2", endpointId: "ep2",
                type: .highErrorRate, severity: .critical, status: .active,
                startedAt: Date().addingTimeInterval(-7200), resolvedAt: nil,
                title: "High Error Rate", description: nil,
                affectedRegions: [], createdAt: Date(), updatedAt: Date()
            ),
        ]
        return vm
    }
}
