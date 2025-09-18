#if canImport(UIKit)
import UIKit
#endif
#if canImport(UserNotifications)
import UserNotifications
#endif

#if canImport(UIKit)

/// ChuckerIOS UI ViewController for displaying network logs
public class ChuckerIOSViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let refreshButton = UIBarButtonItem()
    private let clearButton = UIBarButtonItem()
    private let statusLabel = UILabel()
    
    // MARK: - Data
    private var transactions: [HTTPTransaction] = []
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        setupNotificationObserver()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "🌐 ChuckerIOS Network Monitor"
        view.backgroundColor = .systemBackground
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissViewController)
        )
        
        refreshButton.title = "🔄"
        refreshButton.target = self
        refreshButton.action = #selector(refreshData)
        
        clearButton.title = "🗑️"
        clearButton.target = self
        clearButton.action = #selector(clearData)
        
        navigationItem.rightBarButtonItems = [refreshButton, clearButton]
        
        // Status label
        statusLabel.text = "Loading network data..."
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func loadData() {
        transactions = ChuckerIOS.shared.getAllTransactions()
        updateStatusLabel()
        tableView.reloadData()
    }
    
    private func updateStatusLabel() {
        let totalTransactions = transactions.count
        let errorCount = transactions.filter { $0.error != nil }.count
        let successCount = totalTransactions - errorCount
        
        statusLabel.text = "📊 Total: \(totalTransactions) | ✅ Success: \(successCount) | ❌ Errors: \(errorCount)"
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transactionCaptured),
            name: NSNotification.Name("ChuckerIOSTransactionCaptured"),
            object: nil
        )
    }
    
    @objc private func transactionCaptured(_ notification: Notification) {
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    // MARK: - Actions
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc private func refreshData() {
        loadData()
        tableView.reloadData()
    }
    
    @objc private func clearData() {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "Are you sure you want to clear all network transactions?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            ChuckerIOS.shared.clearTransactions()
            self.loadData()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ChuckerIOSViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only Transactions section
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "🌐 Network Transactions (\(transactions.count))"
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        cell.configure(with: transactions[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChuckerIOSViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = transactions[indexPath.row]
        showTransactionDetail(transaction)
    }
    
    private func showTransactionDetail(_ transaction: HTTPTransaction) {
        let detailVC = TransactionDetailViewController(transaction: transaction)
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

// MARK: - Custom Cells
class TransactionCell: UITableViewCell {
    private let methodLabel = UILabel()
    private let urlLabel = UILabel()
    private let statusLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        methodLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        methodLabel.textColor = .systemBlue
        
        urlLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        urlLabel.numberOfLines = 2
        
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        timeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        timeLabel.textColor = .systemGray
        
        [methodLabel, urlLabel, statusLabel, timeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            statusLabel.centerYAnchor.constraint(equalTo: methodLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            urlLabel.topAnchor.constraint(equalTo: methodLabel.bottomAnchor, constant: 4),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with transaction: HTTPTransaction) {
        methodLabel.text = transaction.request.method
        urlLabel.text = transaction.request.url
        
        if let error = transaction.error {
            statusLabel.text = "❌ Error"
            statusLabel.textColor = .systemRed
        } else if let response = transaction.response {
            let statusCode = response.statusCode
            if statusCode >= 200 && statusCode < 300 {
                statusLabel.text = "✅ \(statusCode)"
                statusLabel.textColor = .systemGreen
            } else if statusCode >= 400 {
                statusLabel.text = "❌ \(statusCode)"
                statusLabel.textColor = .systemRed
            } else {
                statusLabel.text = "⚠️ \(statusCode)"
                statusLabel.textColor = .systemOrange
            }
        } else {
            statusLabel.text = "⏳ Pending"
            statusLabel.textColor = .systemOrange
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        timeLabel.text = formatter.string(from: transaction.timestamp)
        
        // Add duration if available
        if let duration = transaction.duration {
            timeLabel.text = "\(timeLabel.text!) • \(String(format: "%.3fs", duration))"
        }
        
        // Set background color based on status
        if let error = transaction.error {
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        } else if let response = transaction.response {
            if response.statusCode >= 200 && response.statusCode < 300 {
                backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            } else if response.statusCode >= 400 {
                backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            } else {
                backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            }
        } else {
            backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        }
    }
}

// MARK: - Transaction Detail ViewController
class TransactionDetailViewController: UIViewController {
    private let transaction: HTTPTransaction
    private let segmentedControl = UISegmentedControl(items: ["Request", "Response", "Headers"])
    private let textView = UITextView()
    
    init(transaction: HTTPTransaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayTransactionDetails()
    }
    
    private func setupUI() {
        title = "Transaction Details"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissViewController)
        )
        
        // Segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // Text view
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func segmentChanged() {
        displayTransactionDetails()
    }
    
    private func displayTransactionDetails() {
        var details = ""
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Request
            details += "🌐 REQUEST\n"
            details += "Method: \(transaction.request.method)\n"
            details += "URL: \(transaction.request.url)\n\n"
            
            details += "📝 REQUEST BODY:\n"
            if let bodyString = transaction.request.bodyString, !bodyString.isEmpty {
                details += bodyString
            } else {
                details += "No request body"
            }
            
        case 1: // Response
            details += "📥 RESPONSE\n"
            if let response = transaction.response {
                details += "Status: \(response.statusCode)\n"
                details += "MIME Type: \(response.mimeType ?? "Unknown")\n\n"
                
                details += "📝 RESPONSE BODY:\n"
                if let bodyString = response.bodyString, !bodyString.isEmpty {
                    details += bodyString
                } else {
                    details += "No response body"
                }
            } else if let error = transaction.error {
                details += "❌ ERROR\n"
                details += "Code: \(error.code)\n"
                details += "Message: \(error.message)\n"
                details += "Domain: \(error.domain)\n"
            } else {
                details += "⏳ Pending response..."
            }
            
        case 2: // Headers
            details += "📋 REQUEST HEADERS:\n"
            for (key, value) in transaction.request.headers {
                details += "\(key): \(value)\n"
            }
            
            if let response = transaction.response {
                details += "\n📋 RESPONSE HEADERS:\n"
                for (key, value) in response.headers {
                    details += "\(key): \(value)\n"
                }
            }
            
        default:
            break
        }
        
        details += "⏰ TIMESTAMP: \(transaction.timestamp)\n"
        if let duration = transaction.duration {
            details += "⏱️ DURATION: \(String(format: "%.3f", duration))s\n"
        }
        
        textView.text = details
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
}

#endif
