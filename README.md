# ChuckerIOS

🔎 An HTTP inspector for iOS & URLSession (like Charles but on device)  
🔎 iOS & URLSession için HTTP inceleyici (Charles gibi ama cihazda)

ChuckerIOS is an iOS library that allows you to inspect and debug HTTP requests made by your app. It's inspired by the popular [Chucker](https://github.com/ChuckerTeam/chucker) library for Android.

ChuckerIOS, uygulamanızın yaptığı HTTP isteklerini incelemenizi ve debug etmenizi sağlayan bir iOS kütüphanesidir. Android için popüler olan [Chucker](https://github.com/ChuckerTeam/chucker) kütüphanesinden ilham alınmıştır.

## Features / Özellikler

- 📱 **Real-time HTTP monitoring** - See all network requests as they happen  
  **Gerçek zamanlı HTTP izleme** - Tüm ağ isteklerini gerçekleştiği anda görün
- 🔍 **Detailed request/response inspection** - View headers, body, timing, and more  
  **Detaylı istek/yanıt inceleme** - Başlıklar, gövde, zamanlama ve daha fazlasını görüntüleyin
- 🔔 **Push notifications** - Get notified when new requests are made  
  **Push bildirimleri** - Yeni istekler yapıldığında bildirim alın
- 🎯 **Floating button** - Quick access to the inspector  
  **Yüzen buton** - İnceleyiciye hızlı erişim
- 🔍 **Search & filter** - Find specific requests easily  
  **Arama ve filtreleme** - Belirli istekleri kolayca bulun
- 📤 **Export & share** - Share request details  
  **Dışa aktarma ve paylaşma** - İstek detaylarını paylaşın
- 🔒 **Header redaction** - Hide sensitive information  
  **Başlık gizleme** - Hassas bilgileri gizleyin
- 🎨 **Beautiful UI** - Clean, intuitive interface  
  **Güzel arayüz** - Temiz, sezgisel arayüz

## Installation

### Swift Package Manager (Önerilen)

#### Xcode ile Ekleme:

1. **Xcode'da projenizi açın**
2. **File > Add Package Dependencies** menüsüne gidin
3. Repository URL'ini girin: `https://github.com/yourusername/ChuckerIOS.git`
4. **Add Package** butonuna tıklayın
5. Versiyonu seçin (genellikle en son stable version)
6. Target'ınızı seçin ve **Add Package** butonuna tıklayın

#### Package.swift ile Ekleme:

Eğer Package.swift dosyanız varsa, dependencies bölümüne ekleyin:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ChuckerIOS.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["ChuckerIOS"]
    )
]
```

### Manual Installation (Manuel Kurulum)

#### 1. Repository'yi Clone Edin:
```bash
git clone https://github.com/yourusername/ChuckerIOS.git
```

#### 2. Xcode Projesine Ekleme:

**Yöntem A: Drag & Drop**
1. ChuckerIOS klasörünü Xcode projenize sürükleyin
2. "Copy items if needed" seçeneğini işaretleyin
3. Target'ınızı seçin
4. "Create groups" seçeneğini seçin

**Yöntem B: Add Files**
1. Xcode'da projenize sağ tıklayın
2. **Add Files to "YourProject"** seçin
3. ChuckerIOS/Sources/ChuckerIOS klasörünü seçin
4. "Copy items if needed" ve target'ınızı seçin

#### 3. Storyboard Dosyalarını Ekleme:
1. ChuckerIOS.storyboard dosyasını projenize ekleyin
2. Bundle'a dahil edildiğinden emin olun

### CocoaPods (Alternatif)

Podfile'ınıza ekleyin:
```ruby
pod 'ChuckerIOS', :git => 'https://github.com/yourusername/ChuckerIOS.git'
```

Sonra:
```bash
pod install
```

### Carthage (Alternatif)

Cartfile'ınıza ekleyin:
```
github "yourusername/ChuckerIOS"
```

Sonra:
```bash
carthage update
```

## Quick Start

### 1. Import ChuckerIOS

Projenizde ChuckerIOS'u kullanmak için önce import edin:

```swift
import ChuckerIOS
```

### 2. Configure ChuckerIOS

Uygulamanızın başlangıcında (AppDelegate veya SceneDelegate'de) ChuckerIOS'u yapılandırın:

```swift
// AppDelegate.swift veya SceneDelegate.swift
import ChuckerIOS

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // ChuckerIOS yapılandırması
    let configuration = ChuckerConfiguration(
        showNotifications: true,                    // Bildirimleri göster
        redactHeaders: ["Authorization", "Cookie"], // Hassas header'ları gizle
        maxTransactions: 1000,                      // Maksimum transaction sayısı
        enableFloatingButton: true,                 // Floating button'u etkinleştir
        notificationTitle: "Network Activity"       // Bildirim başlığı
    )
    
    // ChuckerIOS'u yapılandır ve başlat
    ChuckerIOS.shared.configure(with: configuration)
    ChuckerIOS.shared.start()
    
    return true
}
```

### 3. Show the Inspector

ChuckerIOS UI'sını göstermek için:

```swift
// Herhangi bir ViewController'da
@IBAction func showNetworkInspector(_ sender: Any) {
    ChuckerIOS.shared.show()
}

// Veya programmatik olarak
ChuckerIOS.shared.show()
```

### 4. Make Network Requests

ChuckerIOS otomatik olarak tüm URLSession isteklerini yakalar:

```swift
// GET Request
let url = URL(string: "https://api.example.com/data")!
let task = URLSession.shared.dataTask(with: url) { data, response, error in
    // Completion handler
    if let data = data {
        print("Data received: \(data)")
    }
}
task.resume()

// POST Request
var request = URLRequest(url: URL(string: "https://api.example.com/post")!)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let postData = ["key": "value"].data(using: .utf8)
request.httpBody = postData

let postTask = URLSession.shared.dataTask(with: request) { data, response, error in
    // Handle response
}
postTask.resume()
```

### 5. Floating Button (Otomatik)

Floating button etkinleştirildiyse, otomatik olarak ekranın sağ alt köşesinde görünür ve tüm network aktivitelerini gösterir.

### 6. Notifications (Otomatik)

Bildirimler etkinleştirildiyse, her yeni network isteği için otomatik bildirim alırsınız.

## Configuration Options

```swift
let configuration = ChuckerConfiguration(
    showNotifications: true,           // Show notifications for new requests
    redactHeaders: ["Authorization"],  // Headers to redact (hide sensitive data)
    maxTransactions: 1000,            // Maximum number of requests to store
    enableFloatingButton: true,       // Show floating button for quick access
    notificationTitle: "ChuckerIOS"   // Custom notification title
)
```

## Usage Examples

### Basic Usage (Temel Kullanım)

```swift
import ChuckerIOS

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ChuckerIOS'u başlat (AppDelegate'de yapılandırıldıysa)
        ChuckerIOS.shared.start()
        
        // API isteği yap
        makeAPIRequest()
    }
    
    private func makeAPIRequest() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Request failed: \(error.localizedDescription)")
                } else {
                    print("Request completed successfully")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func showInspector(_ sender: Any) {
        ChuckerIOS.shared.show()
    }
}
```

### Advanced Configuration (Gelişmiş Yapılandırma)

```swift
// Özel yapılandırma
let configuration = ChuckerConfiguration(
    showNotifications: true,                                    // Bildirimleri göster
    redactHeaders: ["Authorization", "Cookie", "X-API-Key"],   // Hassas header'ları gizle
    maxTransactions: 500,                                       // Maksimum 500 transaction sakla
    enableFloatingButton: true,                                 // Floating button'u etkinleştir
    notificationTitle: "My App Network"                         // Özel bildirim başlığı
)

ChuckerIOS.shared.configure(with: configuration)
ChuckerIOS.shared.start()
```

### Programmatic Access (Programmatik Erişim)

```swift
// Tüm transaction'ları al
let transactions = ChuckerIOS.shared.getAllTransactions()

// Belirli URL'ye göre filtrele
let filteredTransactions = ChuckerIOS.shared.storage?.getTransactions(filteredBy: "api.example.com")

// Hata olan transaction'ları al
let errorTransactions = ChuckerIOS.shared.storage?.getErrorTransactions()

// Tüm transaction'ları temizle
ChuckerIOS.shared.clearTransactions()

// Monitoring'i durdur
ChuckerIOS.shared.stop()
```

### Debug vs Release Configuration (Debug vs Release Yapılandırması)

```swift
#if DEBUG
// Debug modunda ChuckerIOS'u etkinleştir
let configuration = ChuckerConfiguration(
    showNotifications: true,
    redactHeaders: ["Authorization"],
    maxTransactions: 1000,
    enableFloatingButton: true,
    notificationTitle: "Debug Network"
)
ChuckerIOS.shared.configure(with: configuration)
ChuckerIOS.shared.start()
#else
// Release modunda ChuckerIOS'u devre dışı bırak
// ChuckerIOS.shared.stop()
#endif
```

### Custom URLSession ile Kullanım

```swift
// Özel URLSession yapılandırması
let config = URLSessionConfiguration.default
config.timeoutIntervalForRequest = 30
config.timeoutIntervalForResource = 60

let session = URLSession(configuration: config)

// Bu session da ChuckerIOS tarafından yakalanır
let task = session.dataTask(with: url) { data, response, error in
    // Handle response
}
task.resume()
```

### Alamofire ile Kullanım

```swift
import Alamofire
import ChuckerIOS

// Alamofire istekleri de ChuckerIOS tarafından yakalanır
AF.request("https://api.example.com/data")
    .responseJSON { response in
        // Handle response
    }
```

## UI Components

### Transaction List
- Shows all captured HTTP requests
- Search and filter functionality
- Status indicators (success, error, pending)
- Tap to view details

### Transaction Detail
- Complete request/response information
- Headers, body, timing data
- Share functionality
- Copy to clipboard

### Floating Button
- Quick access to the inspector
- Badge showing request count
- Customizable position and appearance

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Architecture

ChuckerIOS uses several key components:

- **URLSessionInterceptor**: Intercepts network requests using method swizzling
- **TransactionStorage**: Manages storage of HTTP transactions
- **NotificationManager**: Handles local notifications
- **FloatingButtonManager**: Manages the floating button UI
- **UI Controllers**: Storyboard-based interface for viewing transactions

## Security Considerations

⚠️ **Important**: ChuckerIOS is designed for development and debugging purposes only. 

- Never use in production builds
- Sensitive data (headers, body) may be stored locally
- Use header redaction to hide sensitive information
- Consider using different configurations for debug/release builds

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Clone the repository
2. Open the project in Xcode
3. Build and run the demo app
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## License

ChuckerIOS is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Acknowledgments

- Inspired by [Chucker](https://github.com/ChuckerTeam/chucker) for Android
- Built with ❤️ for the iOS development community

## Demo App

The repository includes a demo app that shows how to integrate and use ChuckerIOS. Run the demo to see all features in action.

## Troubleshooting (Sorun Giderme)

### Yaygın Sorunlar ve Çözümleri

#### 1. ChuckerIOS UI Açılmıyor
```swift
// Storyboard dosyasının bundle'a dahil edildiğinden emin olun
// Xcode'da ChuckerIOS.storyboard dosyasının Target Membership'ini kontrol edin
```

#### 2. Network İstekleri Yakalanmıyor
```swift
// ChuckerIOS'un başlatıldığından emin olun
ChuckerIOS.shared.start()

// URLSession.shared kullandığınızdan emin olun
// Özel URLSession instance'ları da yakalanır
```

#### 3. Bildirimler Gelmiyor
```swift
// Notification permission'ı kontrol edin
UNUserNotificationCenter.current().getNotificationSettings { settings in
    if settings.authorizationStatus == .denied {
        // Kullanıcıdan permission isteyin
    }
}
```

#### 4. Floating Button Görünmüyor
```swift
// Configuration'da enableFloatingButton: true olduğundan emin olun
let configuration = ChuckerConfiguration(enableFloatingButton: true)
```

#### 5. Build Hatası: "No such module 'ChuckerIOS'"
- Swift Package Manager ile eklediyseniz, package'ın doğru eklendiğini kontrol edin
- Manual installation yaptıysanız, dosyaların doğru target'a eklendiğini kontrol edin
- Clean Build Folder yapın (Product > Clean Build Folder)

#### 6. Storyboard Bulunamıyor Hatası
```swift
// Bundle.module kullanımını kontrol edin
let storyboard = UIStoryboard(name: "ChuckerIOS", bundle: Bundle.module)
```

### Debug Modunda Test Etme

```swift
#if DEBUG
// Debug modunda detaylı log'lar
print("ChuckerIOS: Starting network monitoring")
print("ChuckerIOS: Configuration: \(configuration)")
#endif
```

### Performance İpuçları

```swift
// Büyük uygulamalar için transaction limit'ini ayarlayın
let configuration = ChuckerConfiguration(maxTransactions: 100) // Daha az memory kullanır

// Production'da ChuckerIOS'u devre dışı bırakın
#if !DEBUG
ChuckerIOS.shared.stop()
#endif
```

## Support

Sorun yaşıyorsanız veya sorularınız varsa:

1. [Issues](https://github.com/yourusername/ChuckerIOS/issues) sayfasını kontrol edin
2. Detaylı bilgi ile yeni bir issue oluşturun
3. iOS versiyonu, Xcode versiyonu ve adımları dahil edin

### Katkıda Bulunma

1. Repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

Made with ❤️ for iOS developers
