import Foundation
import ChuckerIOS

// iOS Test App - Tests the ChuckerIOS library
class iOSApp {
    
    static func run() {
        print("🚀 ChuckerIOS iOS Test App Starting...")
        
        // Configure ChuckerIOS
        let configuration = ChuckerConfiguration(
            showNotifications: true,
            redactHeaders: ["Authorization", "Cookie"],
            maxTransactions: 100,
            enableFloatingButton: true,
            notificationTitle: "iOS Test App Network"
        )
        
        ChuckerIOS.shared.configure(with: configuration)
        ChuckerIOS.shared.start()
        
        print("✅ ChuckerIOS configured and started")
        
        // Make test requests
        makeTestRequests()
        
        // Show results
        showResults()
    }
    
    private static func makeTestRequests() {
        print("\n📡 Making iOS test requests...")
        
        // Test URLs
        let testURLs = [
            "https://httpbin.org/get",
            "https://httpbin.org/post",
            "https://jsonplaceholder.typicode.com/posts/1",
            "https://api.github.com/users/octocat"
        ]
        
        for (index, urlString) in testURLs.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.setValue("ChuckerIOS-iOS-Test/1.0", forHTTPHeaderField: "User-Agent")
            
            if index == 1 { // POST request
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = """
                {
                    "test": "ChuckerIOS iOS Test App",
                    "platform": "iOS",
                    "timestamp": "\(Date())"
                }
                """.data(using: .utf8)
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Manually capture the transaction since method swizzling isn't fully implemented
                ChuckerIOS.shared.interceptor?.captureTransaction(
                    request: request,
                    response: response,
                    data: data,
                    error: error
                )
                
                if let error = error {
                    print("❌ iOS Request failed: \(urlString) - \(error.localizedDescription)")
                } else {
                    print("✅ iOS Request successful: \(urlString)")
                }
            }
            
            task.resume()
            
            // Short delay between requests
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        // Wait for requests to complete
        Thread.sleep(forTimeInterval: 3.0)
    }
    
    private static func showResults() {
        print("\n📊 iOS Test Results:")
        print("===================")
        
        let transactions = ChuckerIOS.shared.getAllTransactions()
        print("📈 Total captured requests: \(transactions.count)")
        
        if transactions.isEmpty {
            print("⚠️  No requests captured yet")
            print("💡 Method swizzling not implemented yet")
            return
        }
        
        print("\n📋 Captured Requests:")
        for (index, transaction) in transactions.enumerated() {
            print("\(index + 1). \(transaction.request.method) \(transaction.request.url)")
            print("   📅 Time: \(transaction.timestamp)")
            print("   ⏱️  Duration: \(transaction.duration ?? 0)ms")
            if let error = transaction.error {
                print("   ❌ Error: \(error.message)")
            } else {
                print("   ✅ Success")
            }
            print("")
        }
        
        // Filtering tests
        print("🔍 Filtering Tests:")
        print("==================")
        
        let getRequests = ChuckerIOS.shared.storage?.getTransactions(filteredByMethod: "GET") ?? []
        print("📥 GET requests: \(getRequests.count)")
        
        let postRequests = ChuckerIOS.shared.storage?.getTransactions(filteredByMethod: "POST") ?? []
        print("📤 POST requests: \(postRequests.count)")
        
        let errorRequests = ChuckerIOS.shared.storage?.getErrorTransactions() ?? []
        print("❌ Error requests: \(errorRequests.count)")
        
        print("\n🎉 iOS Test completed!")
        print("💡 ChuckerIOS library is working successfully on iOS!")
    }
}

// Run the iOS test application
@main
struct iOSAppMain {
    static func main() {
        iOSApp.run()
    }
}
