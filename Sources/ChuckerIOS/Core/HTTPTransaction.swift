import Foundation

/// Represents a complete HTTP transaction (request + response)
public struct HTTPTransaction: Codable, Identifiable {
    public let id: String
    public let request: HTTPRequest
    public let response: HTTPResponse?
    public let error: HTTPError?
    public let timestamp: Date
    public let duration: TimeInterval?
    
    public init(
        id: String = UUID().uuidString,
        request: HTTPRequest,
        response: HTTPResponse? = nil,
        error: HTTPError? = nil,
        timestamp: Date = Date(),
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.request = request
        self.response = response
        self.error = error
        self.timestamp = timestamp
        self.duration = duration
    }
}

/// Represents an HTTP request
public struct HTTPRequest: Codable {
    public let method: String
    public let url: String
    public let headers: [String: String]
    public let body: Data?
    public let bodyString: String?
    
    public init(
        method: String,
        url: String,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.bodyString = body?.stringValue
    }
}

/// Represents an HTTP response
public struct HTTPResponse: Codable {
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data?
    public let bodyString: String?
    public let mimeType: String?
    
    public init(
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data? = nil,
        mimeType: String? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.bodyString = body?.stringValue
        self.mimeType = mimeType
    }
}

/// Represents an HTTP error
public struct HTTPError: Codable {
    public let code: Int
    public let message: String
    public let domain: String
    
    public init(code: Int, message: String, domain: String) {
        self.code = code
        self.message = message
        self.domain = domain
    }
}

// MARK: - Extensions

extension Data {
    var stringValue: String? {
        guard let string = String(data: self, encoding: .utf8) else {
            return nil
        }
        return string
    }
}

extension HTTPTransaction {
    /// Returns a user-friendly status description
    public var statusDescription: String {
        if let error = error {
            return "Error: \(error.message)"
        } else if let response = response {
            return "\(response.statusCode)"
        } else {
            return "Pending"
        }
    }
    
    /// Returns the HTTP method with URL for display
    public var displayTitle: String {
        return "\(request.method) \(URL(string: request.url)?.path ?? request.url)"
    }
}
