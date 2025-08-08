//
//  Transaction+Extensions.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import Foundation
import CoreData

// MARK: - Helper Extensions
extension Date {
    // Random date between two dates
    static func random(in range: ClosedRange<Date>) -> Date {
        Date(timeIntervalSinceReferenceDate:
             TimeInterval.random(in: range.lowerBound.timeIntervalSinceReferenceDate...range.upperBound.timeIntervalSinceReferenceDate))
    }
}

// MARK: - Transaction Extensions
extension Transaction {
    
    // MARK: - Convenience Initializers
    
    // Creates a new transaction with required fields
    static func create(
        in context: NSManagedObjectContext,
        amount: Decimal,
        merchant: String,
        category: String = "Other",
        currency: String = "USD",
        paymentMethod: String = "Card",
        notes: String? = nil
    ) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.merchant = merchant
        transaction.category = category
        transaction.currency = currency
        transaction.paymentMethod = paymentMethod
        transaction.notes = notes
        transaction.date = Date()
        transaction.isRecurring = false
        return transaction
    }
    
    // Creates a sample transaction for testing/previews
    static func createSample(in context: NSManagedObjectContext) -> Transaction {
        let merchants = [
            "Starbucks", "Amazon", "Apple Store", "Whole Foods", "Shell",
            "Netflix", "Uber", "Target", "McDonald's", "Best Buy",
            "Costco", "Home Depot", "CVS Pharmacy", "Walgreens", "Chipotle"
        ]
        
        let categories = [
            "Food & Dining", "Shopping", "Technology", "Groceries", "Gas & Fuel",
            "Entertainment", "Transportation", "Shopping", "Food & Dining", "Technology",
            "Shopping", "Bills & Utilities", "Healthcare", "Food & Dining", "Food & Dining"
        ]
        
        let paymentMethods = ["Card", "Cash", "Apple Pay", "Bank Transfer"]
        
        let randomIndex = Int.random(in: 0..<merchants.count)
        let randomAmount = Double.random(in: 3.99...299.99)
        
        // Calculate date range safely
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let now = Date()
        
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(value: randomAmount)
        transaction.merchant = merchants[randomIndex]
        transaction.category = categories[randomIndex]
        transaction.currency = "USD"
        transaction.paymentMethod = paymentMethods.randomElement()!
        transaction.date = Date.random(in: thirtyDaysAgo...now)
        transaction.isRecurring = Bool.random() && randomAmount > 50 // Only expensive items might be recurring
        transaction.notes = Bool.random() ? ["Monthly subscription", "Work expense", "Gift", "Emergency purchase"].randomElement() : nil
        
        return transaction
    }
    
    // Creates multiple sample transactions at once
    static func createSampleBatch(count: Int = 10, in context: NSManagedObjectContext) -> [Transaction] {
        var transactions: [Transaction] = []
        
        for _ in 0..<count {
            let transaction = createSample(in: context)
            transactions.append(transaction)
        }
        
        return transactions
    }
}

// MARK: - Computed Properties
extension Transaction {
    
    // Formatted amount string with currency
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount ?? NSDecimalNumber.zero) ?? "$0.00"
    }
    
    // Short formatted amount (no currency symbol)
    var shortFormattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount ?? NSDecimalNumber.zero) ?? "0.00"
    }
    
    // Formatted amount with plus/minus prefix for expense/income
    var signedFormattedAmount: String {
        let baseAmount = formattedAmount
        // In a real app, you might have income vs expense logic
        // For now, all transactions are expenses (negative)
        return "-\(baseAmount)"
    }
    
    // System icon name for the transaction category
    var categoryIcon: String {
        switch category?.lowercased() {
        case "food & dining", "food", "dining", "restaurant":
            return "fork.knife"
        case "groceries", "grocery", "supermarket":
            return "cart"
        case "shopping", "retail":
            return "bag"
        case "transportation", "transport", "travel":
            return "car"
        case "gas & fuel", "gas", "fuel":
            return "fuelpump"
        case "entertainment", "movies", "games":
            return "tv"
        case "technology", "tech", "electronics":
            return "laptopcomputer"
        case "healthcare", "health", "medical":
            return "cross.case"
        case "bills & utilities", "bills", "utilities":
            return "house"
        case "education", "learning":
            return "book"
        case "fitness", "gym", "sports":
            return "figure.run"
        case "beauty", "personal care":
            return "scissors"
        case "income", "salary", "paycheck":
            return "plus.circle"
        default:
            return "questionmark.circle"
        }
    }
    
    // Color associated with the transaction category
    var categoryColor: String {
        switch category?.lowercased() {
        case "food & dining", "food", "dining":
            return "orange"
        case "groceries", "grocery":
            return "green"
        case "shopping", "retail":
            return "purple"
        case "transportation", "transport":
            return "blue"
        case "gas & fuel", "gas", "fuel":
            return "red"
        case "entertainment":
            return "pink"
        case "technology", "tech":
            return "gray"
        case "healthcare", "health":
            return "red"
        case "bills & utilities", "bills":
            return "yellow"
        case "income", "salary":
            return "green"
        default:
            return "gray"
        }
    }
    
    // Relative date string (Today, Yesterday, etc.)
    var relativeDateString: String {
        guard let date = date else { return "Unknown" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Full formatted date string
    var fullDateString: String {
        guard let date = date else { return "Unknown Date" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Short date string (just the date, no time)
    var shortDateString: String {
        guard let date = date else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    // Whether this transaction happened today
    var isToday: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInToday(date)
    }
    
    // Whether this transaction happened yesterday
    var isYesterday: Bool {
        guard let date = date else { return false }
        return Calendar.current.isDateInYesterday(date)
    }
    
    // Whether this transaction happened this week
    var isThisWeek: Bool {
        guard let date = date else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let weekOfYear = calendar.component(.weekOfYear, from: now)
        let transactionWeekOfYear = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.year, from: now)
        let transactionYear = calendar.component(.year, from: date)
        
        return weekOfYear == transactionWeekOfYear && year == transactionYear
    }
    
    // Whether this transaction happened this month
    var isThisMonth: Bool {
        guard let date = date else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let transactionMonth = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: now)
        let transactionYear = calendar.component(.year, from: date)
        
        return month == transactionMonth && year == transactionYear
    }
    
    // Whether this transaction happened this year
    var isThisYear: Bool {
        guard let date = date else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let transactionYear = calendar.component(.year, from: date)
        
        return year == transactionYear
    }
    
    // Merchant name with proper capitalization
    var displayMerchant: String {
        guard let merchant = merchant, !merchant.isEmpty else {
            return "Unknown Merchant"
        }
        return merchant.capitalized
    }
    
    // Category name with proper capitalization
    var displayCategory: String {
        guard let category = category, !category.isEmpty else {
            return "Other"
        }
        return category.capitalized
    }
}

// MARK: - Validation
extension Transaction {
    
    // Validates if the transaction has all required fields
    var isValid: Bool {
        guard let amount = amount,
              amount.compare(NSDecimalNumber.zero) == .orderedDescending,
              let merchant = merchant, !merchant.isEmpty,
              let category = category, !category.isEmpty,
              date != nil else {
            return false
        }
        return true
    }
    
    // Returns validation error messages
    var validationErrors: [String] {
        var errors: [String] = []
        
        if amount == nil || amount?.compare(NSDecimalNumber.zero) != .orderedDescending {
            errors.append("Amount must be greater than zero")
        }
        
        if merchant?.isEmpty ?? true {
            errors.append("Merchant name is required")
        }
        
        if category?.isEmpty ?? true {
            errors.append("Category is required")
        }
        
        if date == nil {
            errors.append("Date is required")
        }
        
        return errors
    }
    
    // Whether the transaction passes basic validation
    var hasValidationErrors: Bool {
        return !validationErrors.isEmpty
    }
}

// MARK: - Fetch Requests
extension Transaction {
    
    // Fetch request for all transactions, sorted by date (newest first)
    static var allTransactionsFetchRequest: NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for transactions in a specific date range
    static func fetchRequest(from startDate: Date, to endDate: Date) -> NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for transactions in a specific category
    static func fetchRequest(for category: String) -> NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "category LIKE[c] %@", category)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for transactions from a specific merchant
    static func fetchRequest(merchant: String) -> NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "merchant LIKE[c] %@", merchant)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for recurring transactions
    static var recurringTransactionsFetchRequest: NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "isRecurring == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for today's transactions
    static var todaysTransactionsFetchRequest: NSFetchRequest<Transaction> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
    
    // Fetch request for this month's transactions
    static var thisMonthTransactionsFetchRequest: NSFetchRequest<Transaction> {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return request
    }
}

// MARK: - Utility Methods
extension Transaction {
    
    // Returns all unique categories from existing transactions
    static func getAllCategories(in context: NSManagedObjectContext) -> [String] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.propertiesToFetch = ["category"]
        request.returnsDistinctResults = true
        
        do {
            let transactions = try context.fetch(request)
            let categories = transactions.compactMap { $0.category }.sorted()
            return Array(Set(categories)) // Remove duplicates and sort
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // Returns all unique merchants from existing transactions
    static func getAllMerchants(in context: NSManagedObjectContext) -> [String] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.propertiesToFetch = ["merchant"]
        request.returnsDistinctResults = true
        
        do {
            let transactions = try context.fetch(request)
            let merchants = transactions.compactMap { $0.merchant }.sorted()
            return Array(Set(merchants)) // Remove duplicates and sort
        } catch {
            print("Error fetching merchants: \(error)")
            return []
        }
    }
    
    // Calculates total amount for an array of transactions
    static func totalAmount(for transactions: [Transaction]) -> NSDecimalNumber {
        return transactions.reduce(NSDecimalNumber.zero) { result, transaction in
            result.adding(transaction.amount ?? NSDecimalNumber.zero)
        }
    }
    
    // Groups transactions by category with totals
    static func groupByCategory(_ transactions: [Transaction]) -> [(category: String, total: NSDecimalNumber, count: Int)] {
        let grouped = Dictionary(grouping: transactions) { $0.category ?? "Other" }
        
        return grouped.map { category, transactions in
            let total = transactions.reduce(NSDecimalNumber.zero) { result, transaction in
                result.adding(transaction.amount ?? NSDecimalNumber.zero)
            }
            return (category: category, total: total, count: transactions.count)
        }.sorted { $0.total.compare($1.total) == .orderedDescending }
    }
    
    // Duplicate this transaction (useful for recurring transactions)
    func duplicate(in context: NSManagedObjectContext) -> Transaction {
        let newTransaction = Transaction(context: context)
        newTransaction.id = UUID()
        newTransaction.amount = self.amount
        newTransaction.merchant = self.merchant
        newTransaction.category = self.category
        newTransaction.currency = self.currency
        newTransaction.paymentMethod = self.paymentMethod
        newTransaction.notes = self.notes
        newTransaction.date = Date() // Use current date for duplicate
        newTransaction.isRecurring = self.isRecurring
        
        return newTransaction
    }
}


