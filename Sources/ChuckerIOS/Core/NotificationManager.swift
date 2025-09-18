import Foundation
import UserNotifications

/// Manages local notifications for network activity
public class NotificationManager {
    
    private let configuration: ChuckerConfiguration
    
    public init(configuration: ChuckerConfiguration) {
        self.configuration = configuration
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("ChuckerIOS: Failed to request notification permission: \(error)")
            }
        }
    }
    
    public func showNotification(for transaction: HTTPTransaction) {
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
    }
    
    public func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
