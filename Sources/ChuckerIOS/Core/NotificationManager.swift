import Foundation
import UserNotifications
import UIKit

/// Manages local notifications for network activity
public class NotificationManager: NSObject {
    
    private let configuration: ChuckerConfiguration
    private let notificationCenter = UNUserNotificationCenter.current()
    
    public init(configuration: ChuckerConfiguration) {
        self.configuration = configuration
        super.init()
        setupNotificationCenter()
        print("ChuckerIOS: NotificationManager initialized")
    }
    
    private func setupNotificationCenter() {
        notificationCenter.delegate = self
    }
    
    public func showNotification(for transaction: HTTPTransaction) {
        guard configuration.showNotifications else { return }
        
        // Get current transaction count
        let transactionCount = ChuckerIOS.shared.getAllTransactions().count
        
        let content = UNMutableNotificationContent()
        content.title = "🌐 ChuckerIOS Network Monitor"
        content.body = "\(transactionCount) network request(s) captured"
        content.sound = .default
        content.userInfo = [
            "action": "show_chuckerios"
        ]
        
        // Add action button
        let showAction = UNNotificationAction(
            identifier: "SHOW_CHUCKERIOS",
            title: "View All Requests",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "CHUCKERIOS_CATEGORY",
            actions: [showAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "CHUCKERIOS_CATEGORY"
        
        // Use a single notification ID to update the same notification
        let request = UNNotificationRequest(
            identifier: "chuckerios_network_monitor",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("ChuckerIOS: Failed to show notification: \(error)")
            } else {
                print("ChuckerIOS: Notification updated - \(transactionCount) requests captured")
            }
        }
    }
    
    public func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("ChuckerIOS: All notifications cleared")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        print("🔔 ChuckerIOS: Notification received")
        print("🔔 Action ID: \(response.actionIdentifier)")
        print("🔔 UserInfo: \(userInfo)")
        
        if response.actionIdentifier == "SHOW_CHUCKERIOS" || 
           userInfo["action"] as? String == "show_chuckerios" ||
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            
            print("🔔 ChuckerIOS: Notification tapped - showing UI")
            NSLog("🔔 ChuckerIOS: Notification tapped - showing UI")
            
            DispatchQueue.main.async {
                print("🔔 ChuckerIOS: About to call show()")
                ChuckerIOS.shared.show()
                print("🔔 ChuckerIOS: show() called")
            }
        } else {
            print("🔔 ChuckerIOS: Notification action not recognized")
        }
        
        completionHandler()
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
