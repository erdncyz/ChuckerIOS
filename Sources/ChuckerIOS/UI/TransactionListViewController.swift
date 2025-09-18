import UIKit

/// Main view controller that displays the list of HTTP transactions
public class TransactionListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var transactions: [HTTPTransaction] = []
    private var filteredTransactions: [HTTPTransaction] = []
    private var isSearching = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTransactions()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }
    
    private func setupUI() {
        title = "ChuckerIOS"
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        // Setup search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search requests..."
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearButtonTapped)
        )
    }
    
    private func loadTransactions() {
        transactions = ChuckerIOS.shared.getAllTransactions()
        filteredTransactions = transactions
        tableView.reloadData()
    }
    
    @objc private func clearButtonTapped() {
        let alert = UIAlertController(
            title: "Clear Transactions",
            message: "Are you sure you want to clear all transactions?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            ChuckerIOS.shared.clearTransactions()
            self.loadTransactions()
        })
        
        present(alert, animated: true)
    }
    
    private func filterTransactions(with searchText: String) {
        if searchText.isEmpty {
            filteredTransactions = transactions
        } else {
            filteredTransactions = transactions.filter { transaction in
                transaction.request.url.lowercased().contains(searchText.lowercased()) ||
                transaction.request.method.lowercased().contains(searchText.lowercased()) ||
                transaction.statusDescription.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension TransactionListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = filteredTransactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransactionListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = filteredTransactions[indexPath.row]
        let detailVC = TransactionDetailViewController()
        detailVC.transaction = transaction
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UISearchBarDelegate

extension TransactionListViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTransactions(with: searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterTransactions(with: "")
    }
}

// MARK: - TransactionTableViewCell

class TransactionTableViewCell: UITableViewCell {
    
    private let methodLabel = UILabel()
    private let urlLabel = UILabel()
    private let statusLabel = UILabel()
    private let timeLabel = UILabel()
    private let statusIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure method label
        methodLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        methodLabel.textColor = .systemBlue
        
        // Configure URL label
        urlLabel.font = UIFont.systemFont(ofSize: 12)
        urlLabel.textColor = .label
        urlLabel.numberOfLines = 2
        
        // Configure status label
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        // Configure time label
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        timeLabel.textColor = .secondaryLabel
        
        // Configure status indicator
        statusIndicator.layer.cornerRadius = 4
        
        // Add subviews
        contentView.addSubview(methodLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusIndicator)
        
        // Setup constraints
        methodLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            methodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            methodLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            methodLabel.widthAnchor.constraint(equalToConstant: 60),
            
            urlLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            urlLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            urlLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -8),
            
            statusLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            statusLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -8),
            
            timeLabel.leadingAnchor.constraint(equalTo: methodLabel.trailingAnchor, constant: 8),
            timeLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            statusIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 8),
            statusIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with transaction: HTTPTransaction) {
        methodLabel.text = transaction.request.method
        urlLabel.text = URL(string: transaction.request.url)?.path ?? transaction.request.url
        statusLabel.text = transaction.statusDescription
        timeLabel.text = DateFormatter.shortTimeFormatter.string(from: transaction.timestamp)
        
        // Configure status indicator color
        if transaction.error != nil {
            statusIndicator.backgroundColor = .systemRed
        } else if let response = transaction.response {
            if response.statusCode >= 200 && response.statusCode < 300 {
                statusIndicator.backgroundColor = .systemGreen
            } else if response.statusCode >= 400 {
                statusIndicator.backgroundColor = .systemRed
            } else {
                statusIndicator.backgroundColor = .systemOrange
            }
        } else {
            statusIndicator.backgroundColor = .systemGray
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}
