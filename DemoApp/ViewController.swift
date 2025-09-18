import UIKit
import ChuckerIOS

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let apiEndpoints = [
        "https://jsonplaceholder.typicode.com/posts",
        "https://jsonplaceholder.typicode.com/users",
        "https://httpbin.org/get",
        "https://httpbin.org/post",
        "https://httpbin.org/status/404",
        "https://httpbin.org/status/500",
        "https://api.github.com/users/octocat",
        "https://api.github.com/repos/octocat/Hello-World"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "ChuckerIOS Demo"
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Add ChuckerIOS button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "ChuckerIOS",
            style: .plain,
            target: self,
            action: #selector(showChuckerIOS)
        )
    }
    
    @objc private func showChuckerIOS() {
        ChuckerIOS.shared.show()
    }
    
    private func makeRequest(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("ChuckerIOS-Demo/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    private func makePOSTRequest(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ChuckerIOS-Demo/1.0", forHTTPHeaderField: "User-Agent")
        
        let jsonData = """
        {
            "title": "ChuckerIOS Test",
            "body": "This is a test request from ChuckerIOS demo app",
            "userId": 1
        }
        """.data(using: .utf8)
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("POST request failed: \(error.localizedDescription)")
                } else {
                    print("POST request completed successfully")
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiEndpoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = apiEndpoints[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let urlString = apiEndpoints[indexPath.row]
        
        // Show action sheet
        let alert = UIAlertController(title: "Make Request", message: "Choose request type for \(urlString)", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "GET Request", style: .default) { _ in
            self.makeRequest(to: urlString)
        })
        
        alert.addAction(UIAlertAction(title: "POST Request", style: .default) { _ in
            self.makePOSTRequest(to: urlString)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView.cellForRow(at: indexPath)
            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
        }
        
        present(alert, animated: true)
    }
}
