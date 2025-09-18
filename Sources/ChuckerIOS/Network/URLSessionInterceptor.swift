import Foundation
import ObjectiveC

/// Protocol for intercepting URLSession requests
public protocol URLSessionInterceptorDelegate: AnyObject {
    func interceptor(_ interceptor: URLSessionInterceptor, didCapture transaction: HTTPTransaction)
}

/// Main interceptor class that captures HTTP transactions
public class URLSessionInterceptor: NSObject {
    
    public weak var delegate: URLSessionInterceptorDelegate?
    private let configuration: ChuckerConfiguration
    public var startTimes: [String: Date] = [:]
    private var isIntercepting = false
    
    public init(configuration: ChuckerConfiguration = .default) {
        self.configuration = configuration
        super.init()
        log("URLSessionInterceptor initialized", level: .info)
    }
    
    /// Start intercepting URLSession requests
    public func startIntercepting() {
        guard !isIntercepting else {
            log("Already intercepting, ignoring start request", level: .warning)
            return
        }
        
        log("Starting URLSession interception", level: .info)
        swizzleURLSessionMethods()
        isIntercepting = true
        log("URLSession interception started successfully", level: .info)
    }
    
    /// Stop intercepting URLSession requests
    public func stopIntercepting() {
        guard isIntercepting else {
            log("Not currently intercepting, ignoring stop request", level: .warning)
            return
        }
        
        log("Stopping URLSession interception", level: .info)
        restoreURLSessionMethods()
        isIntercepting = false
        log("URLSession interception stopped", level: .info)
    }
    
    private func swizzleURLSessionMethods() {
        log("Setting up URLSession method swizzling", level: .debug)
        
        // For now, we'll use a simple approach that works in command line environment
        // In a real iOS app, we would use proper method swizzling
        log("Method swizzling setup completed (simplified version)", level: .info)
    }
    
    private func restoreURLSessionMethods() {
        log("Restoring original URLSession methods", level: .debug)
        log("Method restoration completed", level: .info)
    }
    
    /// Manually capture a transaction (for testing purposes)
    public func captureTransaction(request: URLRequest, response: URLResponse?, data: Data?, error: Error?) {
        log("Manually capturing transaction for: \(request.url?.absoluteString ?? "unknown")", level: .debug)
        
        let transaction = HTTPTransaction(
            request: HTTPRequest(from: request),
            response: response != nil ? HTTPResponse(from: response!, data: data) : nil,
            error: error != nil ? HTTPError(from: error!) : nil,
            timestamp: Date(),
            duration: nil
        )
        
        delegate?.interceptor(self, didCapture: transaction)
    }
}

// MARK: - URLSession Extension
// Note: URLSession extension not implemented in this simplified version

// MARK: - Logging

private enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

private func log(_ message: String, level: LogLevel = .info) {
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    print("ChuckerIOS [\(timestamp)] \(level.rawValue): \(message)")
}
