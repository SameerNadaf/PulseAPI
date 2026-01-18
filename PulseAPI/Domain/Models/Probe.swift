//
//  Probe.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - Probe Result Status
enum ProbeResultStatus: String, Codable {
    case success
    case error
    case timeout
}

// MARK: - Probe Result
struct ProbeResult: Identifiable, Codable {
    let id: String
    let endpointId: String
    let timestamp: Date
    let status: ProbeResultStatus
    let latencyMs: Double?
    let statusCode: Int?
    let errorMessage: String?
    let region: String // Cloudflare edge region
    
    // MARK: - Computed
    var isSuccess: Bool {
        status == .success
    }
    
    var latencyString: String? {
        guard let latency = latencyMs else { return nil }
        return latency.latencyString
    }
}

// MARK: - Probe Statistics
struct ProbeStatistics: Codable {
    let endpointId: String
    let periodStart: Date
    let periodEnd: Date
    let totalProbes: Int
    let successCount: Int
    let errorCount: Int
    let timeoutCount: Int
    let averageLatencyMs: Double?
    let p50LatencyMs: Double?
    let p95LatencyMs: Double?
    let p99LatencyMs: Double?
    let minLatencyMs: Double?
    let maxLatencyMs: Double?
    
    // MARK: - Computed
    var successRate: Double {
        guard totalProbes > 0 else { return 0 }
        return Double(successCount) / Double(totalProbes)
    }
    
    var errorRate: Double {
        guard totalProbes > 0 else { return 0 }
        return Double(errorCount + timeoutCount) / Double(totalProbes)
    }
    
    var successRatePercentage: String {
        String(format: "%.1f%%", successRate * 100)
    }
}

// MARK: - Latency Data Point (for charts)
struct LatencyDataPoint: Identifiable, Codable {
    let id: String
    let timestamp: Date
    let latencyMs: Double
    let isAnomaly: Bool
    
    init(timestamp: Date, latencyMs: Double, isAnomaly: Bool = false) {
        self.id = UUID().uuidString
        self.timestamp = timestamp
        self.latencyMs = latencyMs
        self.isAnomaly = isAnomaly
    }
}
