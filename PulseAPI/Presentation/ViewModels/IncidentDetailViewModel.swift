//
//  IncidentDetailViewModel.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

@MainActor
final class IncidentDetailViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var error: NetworkError?
    @Published private(set) var incident: Incident?
    @Published private(set) var timeline: [IncidentTimelineEntry] = []
    @Published private(set) var isUpdatingStatus = false
    
    // MARK: - Computed Properties
    var title: String { incident?.title ?? "Loading..." }
    var status: IncidentStatus { incident?.status ?? .active }
    var severity: IncidentSeverity { incident?.severity ?? .minor }
    var startedAt: Date { incident?.startedAt ?? Date() }
    var resolvedAt: Date? { incident?.resolvedAt }
    var duration: String { incident?.durationString ?? "Unknown" }
    var isResolved: Bool { incident?.isResolved ?? false }
    var endpointId: String { incident?.endpointId ?? "" }
    
    // MARK: - Dependencies
    private let incidentId: String
    private let repository: IncidentRepositoryProtocol
    
    // MARK: - Initialization
    init(
        incidentId: String,
        repository: IncidentRepositoryProtocol = IncidentRepository()
    ) {
        self.incidentId = incidentId
        self.repository = repository
    }
    
    // MARK: - Actions
    func loadIncident() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let (incident, timeline) = try await repository.getIncident(id: incidentId)
            self.incident = incident
            self.timeline = timeline
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadIncident()
    }
    
    func updateStatus(to newStatus: IncidentStatus, message: String) async {
        guard !isUpdatingStatus else { return }
        
        isUpdatingStatus = true
        
        do {
            try await repository.updateStatus(
                incidentId: incidentId,
                status: newStatus,
                message: message
            )
            
            // Reload to get updated timeline
            await loadIncident()
        } catch let networkError as NetworkError {
            error = networkError
        } catch {
            self.error = .unknown(error)
        }
        
        isUpdatingStatus = false
    }
    
    func resolve(message: String = "Manually resolved") async {
        await updateStatus(to: .resolved, message: message)
    }
    
    func markInvestigating(message: String = "Investigation started") async {
        await updateStatus(to: .investigating, message: message)
    }
    
    func markIdentified(message: String = "Issue identified") async {
        await updateStatus(to: .identified, message: message)
    }
    
    func markMonitoring(message: String = "Fix deployed, monitoring") async {
        await updateStatus(to: .monitoring, message: message)
    }
    
    // MARK: - Error Handling
    func dismissError() {
        error = nil
    }
}

// MARK: - Preview Helper
extension IncidentDetailViewModel {
    static var preview: IncidentDetailViewModel {
        let vm = IncidentDetailViewModel(incidentId: "preview")
        vm.incident = Incident(
            id: "1",
            endpointId: "ep1",
            type: .latencySpike,
            severity: .major,
            status: .investigating,
            startedAt: Date().addingTimeInterval(-3600),
            resolvedAt: nil,
            title: "Latency Spike Detected",
            description: "Response times have increased significantly above baseline.",
            affectedRegions: ["us-east-1", "eu-west-1"],
            createdAt: Date(),
            updatedAt: Date()
        )
        vm.timeline = [
            IncidentTimelineEntry(
                id: "t1",
                incidentId: "1",
                status: .active,
                message: "Incident detected automatically",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            IncidentTimelineEntry(
                id: "t2",
                incidentId: "1",
                status: .investigating,
                message: "Team is investigating the issue",
                timestamp: Date().addingTimeInterval(-3000)
            ),
        ]
        return vm
    }
}
