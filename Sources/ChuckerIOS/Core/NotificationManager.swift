import Foundation
import UserNotifications

/// Manages local notifications for network activity
@available(iOS 10.0, macOS 10.14, *)
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
        // Note: AppDelegate handles notification delegate to avoid conflicts
        // notificationCenter.delegate = self
    }
    
    @available(iOS 10.0, macOS 10.14, *)
    public func showNotification(for transaction: HTTPTransaction) {
        guard configuration.showNotifications else { return }
        
        // Get current transaction count
        let allTransactions = ChuckerIOS.shared.getAllTransactions()
        let transactionCount = allTransactions.count
        
        // Create a more informative notification body
        let method = transaction.request.method
        let url = transaction.request.url
        let domain = URL(string: url)?.host ?? "Unknown"
        
        let content = UNMutableNotificationContent()
        content.title = "🌐 ChuckerIOS Network Monitor"
        content.body = "\(method) \(domain) • \(transactionCount) total requests"
        content.sound = .default
        content.userInfo = [
            "action": "show_chuckerios",
            "transaction_count": transactionCount
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
@available(iOS 10.0, macOS 10.14, *)
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, macOS 10.14, *)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        print("🔔🔔🔔 ChuckerIOS: Notification received 🔔🔔🔔")
        print("🔔 Action ID: \(response.actionIdentifier)")
        print("🔔 UserInfo: \(userInfo)")
        print("🔔 Default Action ID: \(UNNotificationDefaultActionIdentifier)")
        NSLog("🔔🔔🔔 ChuckerIOS: Notification received - Action ID: \(response.actionIdentifier) 🔔🔔🔔")
        NSLog("🔔 UserInfo: \(userInfo)")
        
        // Check all possible conditions
        let isShowAction = response.actionIdentifier == "SHOW_CHUCKERIOS"
        let isUserInfoAction = userInfo["action"] as? String == "show_chuckerios"
        let isDefaultAction = response.actionIdentifier == UNNotificationDefaultActionIdentifier
        
        print("🔔 isShowAction: \(isShowAction)")
        print("🔔 isUserInfoAction: \(isUserInfoAction)")
        print("🔔 isDefaultAction: \(isDefaultAction)")
        
        if isShowAction || isUserInfoAction || isDefaultAction {
            print("🔔🔔🔔 ChuckerIOS: Notification tapped - showing UI 🔔🔔🔔")
            NSLog("🔔🔔🔔 ChuckerIOS: Notification tapped - showing UI 🔔🔔🔔")
            
            // Try immediate execution first
            print("🔔 ChuckerIOS: Trying immediate show()")
            ChuckerIOS.shared.show()
            
            // Also try with delay as backup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🔔 ChuckerIOS: Trying delayed show()")
                NSLog("🔔 ChuckerIOS: Trying delayed show()")
                ChuckerIOS.shared.show()
            }
        } else {
            print("🔔 ChuckerIOS: Notification action not recognized")
            NSLog("🔔 ChuckerIOS: Notification action not recognized")
        }
        
        completionHandler()
    }
    
    @available(iOS 10.0, macOS 10.14, *)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        #if os(iOS)
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
        #else
        completionHandler([.alert, .sound])
        #endif
    }
}
