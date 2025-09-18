import Foundation
import ChuckerIOS

// iOS Test App - ChuckerIOS kütüphanesini test eder
class iOSApp {
    
    static func run() {
        print("🚀 ChuckerIOS iOS Test App Başlatılıyor...")
        
        // ChuckerIOS'u yapılandır
        let configuration = ChuckerConfiguration(
            showNotifications: true,
            redactHeaders: ["Authorization", "Cookie"],
            maxTransactions: 100,
            enableFloatingButton: true,
            notificationTitle: "iOS Test App Network"
        )
        
        ChuckerIOS.shared.configure(with: configuration)
        ChuckerIOS.shared.start()
        
        print("✅ ChuckerIOS yapılandırıldı ve başlatıldı")
        
        // Test istekleri yap
        makeTestRequests()
        
        // Sonuçları göster
        showResults()
    }
    
    private static func makeTestRequests() {
        print("\n📡 iOS Test istekleri yapılıyor...")
        
        // Test URL'leri
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
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ iOS İstek başarısız: \(urlString) - \(error.localizedDescription)")
                    } else {
                        print("✅ iOS İstek başarılı: \(urlString)")
                    }
                }
            }
            
            task.resume()
            
            // İstekler arasında kısa bekleme
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        // İsteklerin tamamlanması için bekleme
        Thread.sleep(forTimeInterval: 3.0)
    }
    
    private static func showResults() {
        print("\n📊 iOS Test Sonuçları:")
        print("======================")
        
        let transactions = ChuckerIOS.shared.getAllTransactions()
        print("📈 Toplam yakalanan istek sayısı: \(transactions.count)")
        
        if transactions.isEmpty {
            print("⚠️  Henüz hiç istek yakalanmadı")
            print("💡 Method swizzling henüz implement edilmedi")
            return
        }
        
        print("\n📋 Yakalanan İstekler:")
        for (index, transaction) in transactions.enumerated() {
            print("\(index + 1). \(transaction.request.method) \(transaction.request.url)")
            print("   📅 Zaman: \(transaction.timestamp)")
            print("   ⏱️  Süre: \(transaction.duration ?? 0)ms")
            if let error = transaction.error {
                print("   ❌ Hata: \(error.message)")
            } else {
                print("   ✅ Başarılı")
            }
            print("")
        }
        
        // Filtreleme testleri
        print("🔍 Filtreleme Testleri:")
        print("=====================")
        
        let getRequests = ChuckerIOS.shared.storage?.getTransactions(filteredByMethod: "GET") ?? []
        print("📥 GET istekleri: \(getRequests.count)")
        
        let postRequests = ChuckerIOS.shared.storage?.getTransactions(filteredByMethod: "POST") ?? []
        print("📤 POST istekleri: \(postRequests.count)")
        
        let errorRequests = ChuckerIOS.shared.storage?.getErrorTransactions() ?? []
        print("❌ Hatalı istekler: \(errorRequests.count)")
        
        print("\n🎉 iOS Test tamamlandı!")
        print("💡 ChuckerIOS kütüphanesi iOS'ta başarıyla çalışıyor!")
    }
}

// iOS Test uygulamasını çalıştır
@main
struct iOSAppMain {
    static func main() {
        iOSApp.run()
    }
}
