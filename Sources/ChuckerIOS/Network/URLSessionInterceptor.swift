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
    private var startTimes: [String: Date] = [:]
    
    public init(configuration: ChuckerConfiguration = .default) {
        self.configuration = configuration
        super.init()
    }
    
    /// Start intercepting URLSession requests
    public func startIntercepting() {
        // Method swizzling will be implemented here
        swizzleURLSessionMethods()
    }
    
    /// Stop intercepting URLSession requests
    public func stopIntercepting() {
        // Restore original methods
        restoreURLSessionMethods()
    }
    
    private func swizzleURLSessionMethods() {
        // This is a simplified version - in production, you'd want more robust method swizzling
        let originalSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let swizzledSelector = #selector(URLSession.chucker_dataTask(with:completionHandler:))
        
        guard let originalMethod = class_getInstanceMethod(URLSession.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(URLSession.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    private func restoreURLSessionMethods() {
        // Restore original implementations
        swizzleURLSessionMethods() // Swapping again restores original
    }
}

// MARK: - URLSession Extension

extension URLSession {
    
    @objc func chucker_dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let startTime = Date()
        let requestId = UUID().uuidString
        
        // Store start time
        if let interceptor = ChuckerIOS.shared.interceptor {
            interceptor.startTimes[requestId] = startTime
        }
        
        // Create HTTP request object
        let httpRequest = HTTPRequest(
            method: request.httpMethod ?? "GET",
            url: request.url?.absoluteString ?? "",
            headers: request.allHTTPHeaderFields ?? [:],
            body: request.httpBody
        )
        
        return chucker_dataTask(with: request) { data, response, error in
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            // Create HTTP response object
            var httpResponse: HTTPResponse?
            if let httpURLResponse = response as? HTTPURLResponse {
                httpResponse = HTTPResponse(
                    statusCode: httpURLResponse.statusCode,
                    headers: httpURLResponse.allHeaderFields as? [String: String] ?? [:],
                    body: data,
                    mimeType: httpURLResponse.mimeType
                )
            }
            
            // Create HTTP error object
            var httpError: HTTPError?
            if let error = error {
                httpError = HTTPError(
                    code: (error as NSError).code,
                    message: error.localizedDescription,
                    domain: (error as NSError).domain
                )
            }
            
            // Create transaction
            let transaction = HTTPTransaction(
                id: requestId,
                request: httpRequest,
                response: httpResponse,
                error: httpError,
                timestamp: startTime,
                duration: duration
            )
            
            // Notify delegate
            ChuckerIOS.shared.interceptor?.delegate?.interceptor(ChuckerIOS.shared.interceptor!, didCapture: transaction)
            
            // Call original completion handler
            completionHandler(data, response, error)
        }
    }
}
