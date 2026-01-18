//
//  APIEndpoints.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - Endpoints API
enum EndpointsAPI: APIEndpoint {
    case list
    case get(id: String)
    case create(CreateEndpointRequest)
    case update(id: String, UpdateEndpointRequest)
    case delete(id: String)
    case health(id: String)
    
    var path: String {
        switch self {
        case .list:
            return "/v1/endpoints"
        case .get(let id), .update(let id, _), .delete(let id):
            return "/v1/endpoints/\(id)"
        case .create:
            return "/v1/endpoints"
        case .health(let id):
            return "/v1/endpoints/\(id)/health"
        }
    }
    
    var method: HTTPMethodRequest {
        switch self {
        case .list, .get, .health:
            return .get
        case .create:
            return .post
        case .update:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var body: Encodable? {
        switch self {
        case .create(let request):
            return request
        case .update(_, let request):
            return request
        default:
            return nil
        }
    }
}

// MARK: - Incidents API
enum IncidentsAPI: APIEndpoint {
    case list(status: String? = nil, limit: Int = 50)
    case get(id: String)
    case updateStatus(id: String, status: String, message: String)
    case stats
    
    var path: String {
        switch self {
        case .list:
            return "/v1/incidents"
        case .get(let id):
            return "/v1/incidents/\(id)"
        case .updateStatus(let id, _, _):
            return "/v1/incidents/\(id)/status"
        case .stats:
            return "/v1/incidents/stats/summary"
        }
    }
    
    var method: HTTPMethodRequest {
        switch self {
        case .list, .get, .stats:
            return .get
        case .updateStatus:
            return .patch
        }
    }
    
    var body: Encodable? {
        switch self {
        case .updateStatus(_, let status, let message):
            return UpdateStatusRequest(status: status, message: message)
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .list(let status, let limit):
            var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: "\(limit)")]
            if let status = status {
                items.append(URLQueryItem(name: "status", value: status))
            }
            return items
        default:
            return nil
        }
    }
}

// MARK: - Probes API
enum ProbesAPI: APIEndpoint {
    case history(endpointId: String, hours: Int = 24)
    case stats(endpointId: String, hours: Int = 24)
    
    var path: String {
        switch self {
        case .history(let endpointId, _):
            return "/v1/probes/history/\(endpointId)"
        case .stats(let endpointId, _):
            return "/v1/probes/stats/\(endpointId)"
        }
    }
    
    var method: HTTPMethodRequest { .get }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .history(_, let hours), .stats(_, let hours):
            return [URLQueryItem(name: "hours", value: "\(hours)")]
        }
    }
}

// MARK: - Dashboard API
enum DashboardAPI: APIEndpoint {
    case summary
    
    var path: String { "/v1/dashboard" }
    var method: HTTPMethodRequest { .get }
}

// MARK: - Users API
enum UsersAPI: APIEndpoint {
    case me
    case registerDeviceToken(token: String)
    
    var path: String {
        switch self {
        case .me:
            return "/v1/users/me"
        case .registerDeviceToken:
            return "/v1/users/device-token"
        }
    }
    
    var method: HTTPMethodRequest {
        switch self {
        case .me:
            return .get
        case .registerDeviceToken:
            return .post
        }
    }
    
    var body: Encodable? {
        switch self {
        case .registerDeviceToken(let token):
            return DeviceTokenRequest(deviceToken: token)
        default:
            return nil
        }
    }
}

// MARK: - Request DTOs
struct CreateEndpointRequest: Codable {
    let name: String
    let url: String
    let method: String
    let probeIntervalMinutes: Int
    let timeoutSeconds: Int
    let expectedStatusCodes: [Int]
    let headers: [String: String]?
    let body: String?
}

struct UpdateEndpointRequest: Codable {
    let name: String?
    let url: String?
    let method: String?
    let probeIntervalMinutes: Int?
    let timeoutSeconds: Int?
    let expectedStatusCodes: [Int]?
    let isActive: Bool?
}

struct UpdateStatusRequest: Codable {
    let status: String
    let message: String
}

struct DeviceTokenRequest: Codable {
    let deviceToken: String
}
