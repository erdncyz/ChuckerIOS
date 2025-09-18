import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Main ChuckerIOS class - entry point for the library
public class ChuckerIOS {
    
    /// Shared instance
    public static let shared = ChuckerIOS()
    
    /// Current configuration
    public private(set) var configuration: ChuckerConfiguration
    
    /// Network interceptor
    public private(set) var interceptor: URLSessionInterceptor?
    
    /// Transaction storage
    public private(set) var storage: TransactionStorage?
    
    /// Notification manager
    public private(set) var notificationManager: NotificationManager?
    
    /// Floating button manager (not available in this build)
    // public private(set) var floatingButtonManager: FloatingButtonManager?
    
    private init() {
        self.configuration = .default
        log("ChuckerIOS initialized", level: .info)
    }
    
    /// Configure ChuckerIOS with custom settings
    public func configure(with configuration: ChuckerConfiguration) {
        log("Configuring ChuckerIOS with settings: notifications=\(configuration.showNotifications), maxTransactions=\(configuration.maxTransactions)", level: .info)
        self.configuration = configuration
        setupComponents()
    }
    
    /// Start monitoring network requests
    public func start() {
        log("Starting ChuckerIOS network monitoring", level: .info)
        setupComponents()
        interceptor?.startIntercepting()
        log("ChuckerIOS network monitoring started successfully", level: .info)
    }
    
    /// Stop monitoring network requests
    public func stop() {
        log("Stopping ChuckerIOS network monitoring", level: .info)
        interceptor?.stopIntercepting()
        // floatingButtonManager?.hide()
        log("ChuckerIOS network monitoring stopped", level: .info)
    }
    
    /// Show the ChuckerIOS UI
    public func show() {
        print("ChuckerIOS: UI not available in this build")
    }
    
    /// Get all captured transactions
    public func getAllTransactions() -> [HTTPTransaction] {
        return storage?.getAllTransactions() ?? []
    }
    
    /// Clear all transactions
    public func clearTransactions() {
        storage?.clearAll()
    }
    
    private func setupComponents() {
        log("Setting up ChuckerIOS components", level: .debug)
        
        // Setup storage
        if storage == nil {
            storage = TransactionStorage(configuration: configuration)
            log("TransactionStorage initialized", level: .debug)
        }
        
        // Setup interceptor
        if interceptor == nil {
            interceptor = URLSessionInterceptor(configuration: configuration)
            interceptor?.delegate = self
            log("URLSessionInterceptor initialized", level: .debug)
        }
        
        // Setup notification manager
        if notificationManager == nil && configuration.showNotifications {
            notificationManager = NotificationManager(configuration: configuration)
            log("NotificationManager initialized", level: .debug)
        }
        
        // Setup floating button
        // Floating button not available in this build
        log("ChuckerIOS components setup completed", level: .debug)
    }
}

// MARK: - URLSessionInterceptorDelegate

extension ChuckerIOS: URLSessionInterceptorDelegate {
    public func interceptor(_ interceptor: URLSessionInterceptor, didCapture transaction: HTTPTransaction) {
        log("Captured transaction: \(transaction.request.method) \(transaction.request.url)", level: .debug)
        
        // Store transaction
        storage?.store(transaction)
        
        // Show notification if enabled
        if configuration.showNotifications {
            notificationManager?.showNotification(for: transaction)
        }
        
        // Update floating button badge
        // Floating button not available in this build
        
        log("Transaction stored successfully", level: .debug)
    }
}

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
