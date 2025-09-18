import UIKit
import ChuckerIOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure ChuckerIOS
        let configuration = ChuckerConfiguration(
            showNotifications: true,
            redactHeaders: ["Authorization", "Cookie"],
            maxTransactions: 500,
            enableFloatingButton: true,
            notificationTitle: "Network Activity"
        )
        
        ChuckerIOS.shared.configure(with: configuration)
        ChuckerIOS.shared.start()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
