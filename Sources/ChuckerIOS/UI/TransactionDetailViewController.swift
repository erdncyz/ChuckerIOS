import UIKit

/// View controller that displays detailed information about a specific HTTP transaction
public class TransactionDetailViewController: UIViewController {
    
    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    
    public var transaction: HTTPTransaction?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let requestLabel = UILabel()
    private let responseLabel = UILabel()
    private let requestTextView = UITextView()
    private let responseTextView = UITextView()
    private let segmentedControl = UISegmentedControl(items: ["Request", "Response", "Headers"])
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithTransaction()
    }
    
    private func setupUI() {
        title = "Transaction Detail"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareButtonTapped)
        )
        
        // Setup segmented control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Setup labels
        requestLabel.text = "Request"
        requestLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        responseLabel.text = "Response"
        responseLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        // Setup text views
        requestTextView.font = UIFont.systemFont(ofSize: 14)
        requestTextView.isEditable = false
        requestTextView.backgroundColor = .systemGray6
        requestTextView.layer.cornerRadius = 8
        requestTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        responseTextView.font = UIFont.systemFont(ofSize: 14)
        responseTextView.isEditable = false
        responseTextView.backgroundColor = .systemGray6
        responseTextView.layer.cornerRadius = 8
        responseTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(requestLabel)
        contentView.addSubview(requestTextView)
        contentView.addSubview(responseLabel)
        contentView.addSubview(responseTextView)
        
        // Setup constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        requestTextView.translatesAutoresizingMaskIntoConstraints = false
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        responseTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            requestLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            requestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            requestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            requestTextView.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 8),
            requestTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            requestTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            requestTextView.heightAnchor.constraint(equalToConstant: 200),
            
            responseLabel.topAnchor.constraint(equalTo: requestTextView.bottomAnchor, constant: 24),
            responseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            responseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            responseTextView.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 8),
            responseTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            responseTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            responseTextView.heightAnchor.constraint(equalToConstant: 200),
            responseTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureWithTransaction() {
        guard let transaction = transaction else { return }
        
        // Configure request text
        var requestText = "\(transaction.request.method) \(transaction.request.url)\n\n"
        
        if !transaction.request.headers.isEmpty {
            requestText += "Headers:\n"
            for (key, value) in transaction.request.headers {
                requestText += "\(key): \(value)\n"
            }
            requestText += "\n"
        }
        
        if let body = transaction.request.bodyString, !body.isEmpty {
            requestText += "Body:\n\(body)"
        }
        
        requestTextView.text = requestText
        
        // Configure response text
        var responseText = ""
        
        if let response = transaction.response {
            responseText += "Status: \(response.statusCode)\n\n"
            
            if !response.headers.isEmpty {
                responseText += "Headers:\n"
                for (key, value) in response.headers {
                    responseText += "\(key): \(value)\n"
                }
                responseText += "\n"
            }
            
            if let body = response.bodyString, !body.isEmpty {
                responseText += "Body:\n\(body)"
            }
        } else if let error = transaction.error {
            responseText = "Error: \(error.message)\nCode: \(error.code)\nDomain: \(error.domain)"
        } else {
            responseText = "No response data available"
        }
        
        responseTextView.text = responseText
    }
    
    @objc private func segmentChanged() {
        // This would switch between different views (Request, Response, Headers)
        // For now, we'll keep it simple and show both
    }
    
    @objc private func shareButtonTapped() {
        guard let transaction = transaction else { return }
        
        var shareText = "HTTP Transaction Details\n\n"
        shareText += "Method: \(transaction.request.method)\n"
        shareText += "URL: \(transaction.request.url)\n"
        shareText += "Timestamp: \(DateFormatter.detailedFormatter.string(from: transaction.timestamp))\n"
        
        if let duration = transaction.duration {
            shareText += "Duration: \(String(format: "%.2f", duration))s\n"
        }
        
        if let response = transaction.response {
            shareText += "Status: \(response.statusCode)\n"
        } else if let error = transaction.error {
            shareText += "Error: \(error.message)\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityVC, animated: true)
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let detailedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}
