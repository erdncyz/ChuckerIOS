import UIKit
import UserNotifications

/// ChuckerIOS UI ViewController for displaying network logs
public class ChuckerIOSViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let refreshButton = UIBarButtonItem()
    private let clearButton = UIBarButtonItem()
    private let statusLabel = UILabel()
    
    // MARK: - Data
    private var transactions: [HTTPTransaction] = []
    private var logs: [String] = []
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        startLogMonitoring()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
        navigationItem.rightBarButtonItem = refreshButton
        
        // Status label
        statusLabel.text = "Loading network data..."
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NetworkLogCell.self, forCellReuseIdentifier: "NetworkLogCell")
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
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
    
    private func startLogMonitoring() {
        // Monitor for new transactions
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadData()
            }
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
}

// MARK: - UITableViewDataSource
extension ChuckerIOSViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Logs section and Transactions section
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return logs.count
        case 1: return transactions.count
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "📝 Recent Logs"
        case 1: return "🌐 Network Transactions"
        default: return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkLogCell", for: indexPath) as! NetworkLogCell
            cell.configure(with: logs[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            cell.configure(with: transactions[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension ChuckerIOSViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let transaction = transactions[indexPath.row]
            showTransactionDetail(transaction)
        }
    }
    
    private func showTransactionDetail(_ transaction: HTTPTransaction) {
        let detailVC = TransactionDetailViewController(transaction: transaction)
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

// MARK: - Custom Cells
class NetworkLogCell: UITableViewCell {
    private let logLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        logLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        logLabel.numberOfLines = 0
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logLabel)
        
        NSLayoutConstraint.activate([
            logLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with log: String) {
        logLabel.text = log
    }
}

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
            statusLabel.text = "✅ \(response.statusCode)"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "⏳ Pending"
            statusLabel.textColor = .systemOrange
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        timeLabel.text = formatter.string(from: transaction.timestamp)
    }
}

// MARK: - Transaction Detail ViewController
class TransactionDetailViewController: UIViewController {
    private let transaction: HTTPTransaction
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
        
        textView.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func displayTransactionDetails() {
        var details = ""
        
        details += "🌐 REQUEST\n"
        details += "Method: \(transaction.request.method)\n"
        details += "URL: \(transaction.request.url)\n"
        details += "Headers: \(transaction.request.headers)\n"
        if let body = transaction.request.body {
            details += "Body: \(body)\n"
        }
        details += "\n"
        
        if let response = transaction.response {
            details += "📡 RESPONSE\n"
            details += "Status: \(response.statusCode)\n"
            details += "Headers: \(response.headers)\n"
            if let body = response.body {
                details += "Body: \(body)\n"
            }
            details += "\n"
        }
        
        if let error = transaction.error {
            details += "❌ ERROR\n"
            details += "Message: \(error.message)\n"
            details += "Code: \(error.code)\n"
            details += "\n"
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
