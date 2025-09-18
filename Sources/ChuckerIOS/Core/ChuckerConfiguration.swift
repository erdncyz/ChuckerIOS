import Foundation

/// Configuration options for ChuckerIOS
public struct ChuckerConfiguration {
    /// Whether to show notifications for new requests
    public let showNotifications: Bool
    
    /// Whether to redact sensitive headers
    public let redactHeaders: Set<String>
    
    /// Maximum number of transactions to keep in memory
    public let maxTransactions: Int
    
    /// Whether to enable the floating button
    public let enableFloatingButton: Bool
    
    /// Custom notification title
    public let notificationTitle: String
    
    public init(
        showNotifications: Bool = true,
        redactHeaders: Set<String> = ["Authorization", "Cookie", "Set-Cookie"],
        maxTransactions: Int = 1000,
        enableFloatingButton: Bool = true,
        notificationTitle: String = "ChuckerIOS"
    ) {
        self.showNotifications = showNotifications
        self.redactHeaders = redactHeaders
        self.maxTransactions = maxTransactions
        self.enableFloatingButton = enableFloatingButton
        self.notificationTitle = notificationTitle
    }
}

/// Default configuration
public extension ChuckerConfiguration {
    static let `default` = ChuckerConfiguration()
}
