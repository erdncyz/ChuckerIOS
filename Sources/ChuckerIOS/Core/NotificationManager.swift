import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Manages local notifications for network activity
public class NotificationManager {
    
    private let configuration: ChuckerConfiguration
    
    public init(configuration: ChuckerConfiguration) {
        self.configuration = configuration
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("ChuckerIOS: Failed to request notification permission: \(error)")
            }
        }
        #endif
    }
    
    public func showNotification(for transaction: HTTPTransaction) {
        #if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = configuration.notificationTitle
        content.body = "\(transaction.request.method) \(URL(string: transaction.request.url)?.path ?? transaction.request.url)"
        content.sound = .default
        
        // Add transaction ID to user info for potential deep linking
        content.userInfo = ["transactionId": transaction.id]
        
        let request = UNNotificationRequest(
            identifier: transaction.id,
            content: content,
            trigger: nil // Show immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("ChuckerIOS: Failed to show notification: \(error)")
            }
        }
        #endif
    }
    
    public func clearAllNotifications() {
        #if canImport(UserNotifications)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        #endif
    }
}
