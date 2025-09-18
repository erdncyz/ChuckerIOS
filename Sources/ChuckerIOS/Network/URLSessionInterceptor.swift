import Foundation
import ObjectiveC
import Alamofire

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
        
        // Setup both URLProtocol and Alamofire interceptor
        setupURLProtocol()
        setupAlamofireInterceptor()
        
        log("URLSessionInterceptor initialized for ALAMOFIRE ONLY", level: .info)
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
    
    // MARK: - Configuration Management (Alamofire Only)
    
    private func setupURLProtocol() {
        // Register URLProtocol to intercept all network requests
        // We'll filter them to only show Alamofire requests
        URLProtocol.registerClass(ChuckerURLProtocol.self)
        log("URLProtocol registered for Alamofire filtering", level: .info)
    }
    
    private func setupAlamofireInterceptor() {
        // Create our custom Alamofire interceptor
        let chuckerInterceptor = ChuckerAlamofireInterceptor()
        
        // Store the interceptor globally so it can be used
        ChuckerIOS.shared.alamofireInterceptor = chuckerInterceptor
        
        // Create a custom Session with our EventMonitor
        let configuration = URLSessionConfiguration.default
        let session = Session(configuration: configuration, eventMonitors: [chuckerInterceptor])
        ChuckerIOS.shared.customSession = session
        
        // Try to add our interceptor to the default session
        setupDefaultSessionInterceptor()
        
        log("ChuckerAlamofireInterceptor created and custom Session configured", level: .info)
    }
    
    private func setupDefaultSessionInterceptor() {
        // Try to add our interceptor to Session.default using reflection
        // This is a workaround since Session.default.eventMonitor is read-only
        if let defaultSession = Session.default as? Session {
            // We can't modify the default session directly, but we can try to intercept at a lower level
            log("Attempting to intercept default Alamofire session", level: .info)
            
            // Store reference for potential future use
            ChuckerIOS.shared.defaultSession = defaultSession
        }
    }
    
}

// MARK: - Alamofire Only Mode
// URLProtocol and method swizzling removed - only Alamofire interceptor is active

// MARK: - Logging

private func log(_ message: String, level: LogLevel = .info) {
    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    let logMessage = "ChuckerIOS [\(timestamp)] \(level.rawValue): \(message)"
    
    // Always print to console
    print(logMessage)
    
    // Also use NSLog for better visibility on device
    NSLog(logMessage)
}


// MARK: - ChuckerAlamofireInterceptor

public class ChuckerAlamofireInterceptor: EventMonitor {
    
    // MARK: - EventMonitor
    
    public func requestDidFinish(_ request: Request) {
        // This is called when the request finishes
        guard let urlRequest = request.request else { return }
        
        let startTime = ChuckerIOS.shared.interceptor?.startTimes[urlRequest.url?.absoluteString ?? ""] ?? Date()
        let duration = Date().timeIntervalSince(startTime)
        
        // Get response data from the request
        var responseData: Data?
        var response: URLResponse?
        var error: Error?
        
        if let dataResponse = request.task?.response as? HTTPURLResponse {
            response = dataResponse
        }
        
        if let dataTask = request.task as? URLSessionDataTask {
            // Try to get response data if available
            responseData = nil // Alamofire handles this internally
        }
        
        // Create transaction
        let transaction = HTTPTransaction(
            request: HTTPRequest(from: urlRequest),
            response: response != nil ? HTTPResponse(from: response!, data: responseData) : nil,
            error: error != nil ? HTTPError(from: error!) : nil,
            timestamp: startTime,
            duration: duration
        )
        
        // Notify ChuckerIOS
        if let interceptor = ChuckerIOS.shared.interceptor {
            ChuckerIOS.shared.interceptor(interceptor, didCapture: transaction)
        }
        
        // Log capture (reduced verbosity)
        if let url = urlRequest.url?.absoluteString {
            log("ALAMOFIRE CAPTURED: \(urlRequest.httpMethod ?? "GET") \(url)", level: .debug)
        }
        
        // Clean up start time
        if let url = urlRequest.url?.absoluteString {
            ChuckerIOS.shared.interceptor?.startTimes.removeValue(forKey: url)
        }
    }
    
    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        // This is called when the response is parsed
        guard let urlRequest = request.request else { return }
        
        let startTime = ChuckerIOS.shared.interceptor?.startTimes[urlRequest.url?.absoluteString ?? ""] ?? Date()
        let duration = Date().timeIntervalSince(startTime)
        
        // Create transaction with response data
        let transaction = HTTPTransaction(
            request: HTTPRequest(from: urlRequest),
            response: response.response != nil ? HTTPResponse(from: response.response!, data: response.data) : nil,
            error: response.error != nil ? HTTPError(from: response.error!) : nil,
            timestamp: startTime,
            duration: duration
        )
        
        // Notify ChuckerIOS
        if let interceptor = ChuckerIOS.shared.interceptor {
            ChuckerIOS.shared.interceptor(interceptor, didCapture: transaction)
        }
        
        // Log capture (reduced verbosity)
        if let url = urlRequest.url?.absoluteString {
            log("ALAMOFIRE CAPTURED: \(urlRequest.httpMethod ?? "GET") \(url)", level: .debug)
        }
        
        // Clean up start time
        if let url = urlRequest.url?.absoluteString {
            ChuckerIOS.shared.interceptor?.startTimes.removeValue(forKey: url)
        }
    }
    
    public func requestDidResume(_ request: Request) {
        // This is called when the request starts
        if let urlRequest = request.request {
            let startTime = Date()
            
            // Store start time for duration calculation
            if let url = urlRequest.url?.absoluteString {
                ChuckerIOS.shared.interceptor?.startTimes[url] = startTime
                
                log("Alamofire request started: \(url)", level: .debug)
            }
        }
    }
}

// MARK: - ChuckerURLProtocol

class ChuckerURLProtocol: URLProtocol {
    
    private var dataTask: URLSessionDataTask?
    private var startTime: Date?
    
    override class func canInit(with request: URLRequest) -> Bool {
        // Only intercept requests that look like they're from Alamofire
        // Check for Alamofire-specific headers or patterns
        if let userAgent = request.value(forHTTPHeaderField: "User-Agent"),
           userAgent.contains("Alamofire") {
            return true
        }
        
        // Also check for requests that might be from the app's API calls
        if let url = request.url?.absoluteString,
           url.contains("mobileservice.apac.beiniz.biz") ||
           url.contains("sdp-cloud-project.apac.beiniz.biz") {
            return true
        }
        
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        startTime = Date()
        
        // Store start time for duration calculation
        if let url = request.url?.absoluteString {
            ChuckerIOS.shared.interceptor?.startTimes[url] = startTime!
        }
        
        // Create a new session to avoid infinite recursion
        let config = URLSessionConfiguration.default
        config.protocolClasses = [] // Don't include our protocol to avoid recursion
        let session = URLSession(configuration: config)
        
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Calculate duration
            let duration = self.startTime.map { Date().timeIntervalSince($0) * 1000 }
            
            // Create transaction
            let transaction = HTTPTransaction(
                request: HTTPRequest(from: self.request),
                response: response != nil ? HTTPResponse(from: response!, data: data) : nil,
                error: error != nil ? HTTPError(from: error!) : nil,
                timestamp: self.startTime ?? Date(),
                duration: duration
            )
            
            // Notify ChuckerIOS
            if let interceptor = ChuckerIOS.shared.interceptor {
                ChuckerIOS.shared.interceptor(interceptor, didCapture: transaction)
            }
            
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
            
            // Clean up start time
            if let url = self.request.url?.absoluteString {
                ChuckerIOS.shared.interceptor?.startTimes.removeValue(forKey: url)
            }
        }
        
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
        dataTask = nil
    }
}

// MARK: - Alamofire Integration
// Note: Method swizzling approach removed due to complexity
// The ChuckerAlamofireInterceptor is created and stored globally
// It needs to be manually added to Alamofire Session instances

