import Foundation
import UIKit
import UserNotifications

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
    
    /// Floating button manager
    public private(set) var floatingButtonManager: FloatingButtonManager?
    
    private init() {
        self.configuration = .default
    }
    
    /// Configure ChuckerIOS with custom settings
    public func configure(with configuration: ChuckerConfiguration) {
        self.configuration = configuration
        setupComponents()
    }
    
    /// Start monitoring network requests
    public func start() {
        setupComponents()
        interceptor?.startIntercepting()
    }
    
    /// Stop monitoring network requests
    public func stop() {
        interceptor?.stopIntercepting()
        floatingButtonManager?.hide()
    }
    
    /// Show the ChuckerIOS UI
    public func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let storyboard = UIStoryboard(name: "ChuckerIOS", bundle: Bundle.module)
        guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        window.rootViewController?.present(navigationController, animated: true)
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
        // Setup storage
        if storage == nil {
            storage = TransactionStorage(configuration: configuration)
        }
        
        // Setup interceptor
        if interceptor == nil {
            interceptor = URLSessionInterceptor(configuration: configuration)
            interceptor?.delegate = self
        }
        
        // Setup notification manager
        if notificationManager == nil && configuration.showNotifications {
            notificationManager = NotificationManager(configuration: configuration)
        }
        
        // Setup floating button
        if floatingButtonManager == nil && configuration.enableFloatingButton {
            floatingButtonManager = FloatingButtonManager()
        }
    }
}

// MARK: - URLSessionInterceptorDelegate

extension ChuckerIOS: URLSessionInterceptorDelegate {
    public func interceptor(_ interceptor: URLSessionInterceptor, didCapture transaction: HTTPTransaction) {
        // Store transaction
        storage?.store(transaction)
        
        // Show notification if enabled
        if configuration.showNotifications {
            notificationManager?.showNotification(for: transaction)
        }
        
        // Update floating button badge
        floatingButtonManager?.updateBadge(count: storage?.getAllTransactions().count ?? 0)
    }
}
