//
//  DashboardViewModel.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import Foundation
import CoreData
import Combine

class DashboardViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var currentBalance: NSDecimalNumber = NSDecimalNumber(value: 2500.00) // Starting balance
    @Published var monthlySpending: NSDecimalNumber = NSDecimalNumber.zero
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadDashboardData()
    }
    
    func loadDashboardData() {
        isLoading = true
        
        // Fetch recent transactions
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        request.fetchLimit = 10 // Only recent 10 for dashboard
        
        do {
            transactions = try context.fetch(request)
            calculateBalance()
            calculateMonthlySpending()
        } catch {
            print("Error fetching transactions: \(error)")
        }
        
        isLoading = false
    }
    
    private func calculateBalance() {
        // Calculate balance = starting amount - total spending
        let totalSpending = transactions.reduce(NSDecimalNumber.zero) { result, transaction in
            result.adding(transaction.amount ?? NSDecimalNumber.zero)
        }
        currentBalance = NSDecimalNumber(value: 2500.00).subtracting(totalSpending)
    }
    
    private func calculateMonthlySpending() {
        let calendar = Calendar.current
        let now = Date()
        let thisMonth = calendar.dateInterval(of: .month, for: now)
        
        monthlySpending = transactions
            .filter { transaction in
                guard let date = transaction.date,
                      let thisMonth = thisMonth else { return false }
                return thisMonth.contains(date)
            }
            .reduce(NSDecimalNumber.zero) { result, transaction in
                result.adding(transaction.amount ?? NSDecimalNumber.zero)
            }
    }
    
    func addSampleTransaction() {
        let newTransaction = Transaction.createSample(in: context)
        
        do {
            try context.save()
            loadDashboardData() // Refresh the data
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    /// Formatted average transaction amount
    var averageTransactionAmount: String {
        guard !transactions.isEmpty else { return "$0.00" }
        
        let total = transactions.reduce(NSDecimalNumber.zero) { result, transaction in
            result.adding(transaction.amount ?? NSDecimalNumber.zero)
        }
        
        let average = total.dividing(by: NSDecimalNumber(value: transactions.count))
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: average) ?? "$0.00"
    }
    
    /// Formatted monthly spending
    var monthlySpendingFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: monthlySpending) ?? "$0.00"
    }
    
    /// Refresh method for pull-to-refresh
    @MainActor
    func refresh() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        loadDashboardData()
        isLoading = false
    }
}
