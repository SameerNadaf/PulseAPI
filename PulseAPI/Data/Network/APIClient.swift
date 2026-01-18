//
//  APIClient.swift
//  PulseAPI
//
//  Created by Sameer Nadaf on 18/01/26.
//

import Foundation

// MARK: - API Client
@MainActor
final class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // User ID for authentication (TODO: Replace with proper auth)
    @Published var userId: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout * 2
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Base Request
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        expecting: T.Type
    ) async throws -> T {
        let request = try buildRequest(for: endpoint)
        
        let (data, response) = try await performRequest(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
        }
        
        try validateResponse(httpResponse, data: data)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Request with retry
    func requestWithRetry<T: Decodable>(
        _ endpoint: APIEndpoint,
        expecting: T.Type,
        maxRetries: Int = APIConfig.maxRetries
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await request(endpoint, expecting: T.self)
            } catch let error as NetworkError {
                lastError = error
                if !error.isRetryable || attempt == maxRetries - 1 {
                    throw error
                }
                // Exponential backoff
                let delay = pow(2.0, Double(attempt)) * APIConfig.retryDelay
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                throw error
            }
        }
        
        throw lastError ?? NetworkError.unknown(NSError(domain: "Unknown error", code: 0))
    }
    
    // MARK: - Build Request
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: APIConfig.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIConfig.apiVersion, forHTTPHeaderField: "X-API-Version")
        
        // Add user ID header
        if let userId = userId {
            request.setValue(userId, forHTTPHeaderField: "X-User-ID")
        }
        
        // Add body if present
        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }
        
        // Add query parameters
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            request.url = components?.url
        }
        
        return request
    }
    
    // MARK: - Perform Request
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Validate Response
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return // Success
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            let message = try? decoder.decode(APIErrorResponse.self, from: data).error
            throw NetworkError.serverError(statusCode: response.statusCode, message: message)
        default:
            let message = try? decoder.decode(APIErrorResponse.self, from: data).error
            throw NetworkError.serverError(statusCode: response.statusCode, message: message)
        }
    }
}

// MARK: - API Error Response
struct APIErrorResponse: Decodable {
    let success: Bool
    let error: String?
}

// MARK: - HTTP Method
enum HTTPMethodRequest: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethodRequest { get }
    var body: Encodable? { get }
    var queryItems: [URLQueryItem]? { get }
}

// Default implementations
extension APIEndpoint {
    var body: Encodable? { nil }
    var queryItems: [URLQueryItem]? { nil }
}

// MARK: - Type-erased Encodable wrapper
struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        self.encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
