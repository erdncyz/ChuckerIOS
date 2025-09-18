import Foundation

/// Manages storage of HTTP transactions
public class TransactionStorage {
    
    private let configuration: ChuckerConfiguration
    private var transactions: [HTTPTransaction] = []
    private let queue = DispatchQueue(label: "com.chuckerios.storage", attributes: .concurrent)
    
    public init(configuration: ChuckerConfiguration) {
        self.configuration = configuration
    }
    
    /// Store a new transaction
    public func store(_ transaction: HTTPTransaction) {
        queue.async(flags: .barrier) {
            self.transactions.append(transaction)
            
            // Limit the number of stored transactions
            if self.transactions.count > self.configuration.maxTransactions {
                self.transactions.removeFirst(self.transactions.count - self.configuration.maxTransactions)
            }
        }
    }
    
    /// Get all transactions
    public func getAllTransactions() -> [HTTPTransaction] {
        return queue.sync {
            return transactions.sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    /// Get transactions filtered by URL
    public func getTransactions(filteredBy url: String) -> [HTTPTransaction] {
        return queue.sync {
            return transactions.filter { $0.request.url.contains(url) }
                .sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    /// Get transactions filtered by method
    public func getTransactions(filteredByMethod method: String) -> [HTTPTransaction] {
        return queue.sync {
            return transactions.filter { $0.request.method.uppercased() == method.uppercased() }
                .sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    /// Get transactions with errors
    public func getErrorTransactions() -> [HTTPTransaction] {
        return queue.sync {
            return transactions.filter { $0.error != nil }
                .sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    /// Clear all transactions
    public func clearAll() {
        queue.async(flags: .barrier) {
            self.transactions.removeAll()
        }
    }
    
    /// Get transaction count
    public func getTransactionCount() -> Int {
        return queue.sync {
            return transactions.count
        }
    }
    
    /// Get error count
    public func getErrorCount() -> Int {
        return queue.sync {
            return transactions.filter { $0.error != nil }.count
        }
    }
}
