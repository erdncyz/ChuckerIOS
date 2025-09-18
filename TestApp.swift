import Foundation

// Basit test uygulaması
print("ChuckerIOS Test App")
print("==================")

// Test HTTP request
let url = URL(string: "https://httpbin.org/get")!
let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("Error: \(error.localizedDescription)")
    } else if let data = data {
        print("Success: Received \(data.count) bytes")
    }
}

print("Making HTTP request to: \(url)")
task.resume()

// Keep the program running
RunLoop.main.run()
