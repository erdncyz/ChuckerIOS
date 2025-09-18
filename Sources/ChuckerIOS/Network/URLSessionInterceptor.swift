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
    public var isIntercepting = false
    
    public init(configuration: ChuckerConfiguration = .default) {
        self.configuration = configuration
        super.init()
        
        // Register URLProtocol immediately to ensure early interception
        URLProtocol.registerClass(ChuckerURLProtocol.self)
        log("URLSessionInterceptor initialized and URLProtocol registered", level: .info)
        
        // Add visible startup message
        print("🌐🌐🌐 URLSessionInterceptor is READY to capture network requests! 🌐🌐🌐")
        NSLog("🌐🌐🌐 URLSessionInterceptor is READY to capture network requests! 🌐🌐🌐")
    }
    
    /// Start intercepting URLSession requests
    public func startIntercepting() {
        guard !isIntercepting else {
            log("Already intercepting, ignoring start request", level: .warning)
            return
        }
        
        log("Starting URLSession interception", level: .info)
        // URLProtocol is already registered in init, just mark as intercepting
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
        isIntercepting = false
        log("URLSession interception stopped", level: .info)
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

// MARK: - ChuckerURLProtocol

class ChuckerURLProtocol: URLProtocol {
    
    private var dataTask: URLSessionDataTask?
    private var startTime: Date?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Only intercept HTTP/HTTPS requests
        guard let scheme = request.url?.scheme else { return false }
        guard scheme == "http" || scheme == "https" else { return false }
        
        // Log when we're checking a request
        log("🔍 ChuckerIOS: Checking request: \(request.url?.absoluteString ?? "unknown")", level: .debug)
        
        // Always intercept when ChuckerIOS is available (don't check isIntercepting flag)
        // This ensures we capture all requests
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        log("🔍 ChuckerIOS: Intercepting request: \(request.url?.absoluteString ?? "unknown")", level: .debug)
        
        startTime = Date()
        
        // Create a new URLSession to handle the request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Calculate duration
            let duration = self.startTime?.timeIntervalSinceNow.magnitude
            
            // Create transaction
            let transaction = HTTPTransaction(
                request: HTTPRequest(from: self.request),
                response: response != nil ? HTTPResponse(from: response!, data: data) : nil,
                error: error != nil ? HTTPError(from: error!) : nil,
                timestamp: self.startTime ?? Date(),
                duration: duration
            )
            
            // Notify interceptor
            ChuckerIOS.shared.interceptor?.delegate?.interceptor(ChuckerIOS.shared.interceptor!, didCapture: transaction)
            
            // Add visible capture message
            print("📡📡📡 ChuckerIOS CAPTURED: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown") 📡📡📡")
            NSLog("📡📡📡 ChuckerIOS CAPTURED: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "unknown") 📡📡📡")
            
            // Forward the response to the original client
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
}

// MARK: - URLSession Extension
// Note: Method swizzling extension removed for now - using URLProtocol approach

// MARK: - Logging

// Logging functions are now in ChuckerIOS.swift
