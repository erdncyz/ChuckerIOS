import Foundation

/// Manages local notifications for network activity
public class NotificationManager {
    
    private let configuration: ChuckerConfiguration
    
    public init(configuration: ChuckerConfiguration) {
        self.configuration = configuration
        print("ChuckerIOS: NotificationManager initialized")
    }
    
    public func showNotification(for transaction: HTTPTransaction) {
        print("ChuckerIOS: Notification for \(transaction.request.method) \(transaction.request.url)")
    }
    
    public func clearAllNotifications() {
        print("ChuckerIOS: Clear notifications called")
    }
}
