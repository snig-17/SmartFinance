//
//  TransactionListView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import SwiftUI
import CoreData

struct TransactionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedTimeFilter = "All Time"
    @State private var showingAddTransaction = false
    
    // Fetch all transactions
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    )
    var allTransactions: FetchedResults<Transaction>
   
    
    private let categories = ["All", "Food & Dining", "Groceries", "Shopping", "Transportation", "Gas & Fuel", "Entertainment", "Technology", "Healthcare", "Bills & Utilities", "Education", "Fitness", "Beauty", "Other"]
    
    private let timeFilters = ["All Time", "Today", "This Week", "This Month", "This Year"]
    
    var filteredTransactions: [Transaction] {
        var filtered = Array(allTransactions)
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.merchant?.localizedCaseInsensitiveContains(searchText) == true ||
                transaction.category?.localizedCaseInsensitiveContains(searchText) == true ||
                transaction.notes?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by time
        switch selectedTimeFilter {
        case "Today":
            filtered = filtered.filter { $0.isToday }
        case "This Week":
            filtered = filtered.filter { $0.isThisWeek }
        case "This Month":
            filtered = filtered.filter { $0.isThisMonth }
        case "This Year":
            filtered = filtered.filter { $0.isThisYear }
        default:
            break
        }
        
        return filtered
    }
    
    var totalAmount: NSDecimalNumber {
        filteredTransactions.reduce(NSDecimalNumber.zero) { result, transaction in
            result.adding(transaction.amount ?? NSDecimalNumber.zero)
        }
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: totalAmount) ?? "$0.00"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(filteredTransactions.count) Transactions")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Total: \(formattedTotal)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAddTransaction = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Filter Controls
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Category Filter
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(category) {
                                        selectedCategory = category
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategory)
                                        .font(.caption)
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory != "All" ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory != "All" ? .white : .primary)
                                .clipShape(Capsule())
                            }
                            
                            // Time Filter
                            Menu {
                                ForEach(timeFilters, id: \.self) { timeFilter in
                                    Button(timeFilter) {
                                        selectedTimeFilter = timeFilter
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedTimeFilter)
                                        .font(.caption)
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTimeFilter != "All Time" ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTimeFilter != "All Time" ? .white : .primary)
                                .clipShape(Capsule())
                            }
                            
                            // Clear Filters
                            if selectedCategory != "All" || selectedTimeFilter != "All Time" {
                                Button("Clear") {
                                    selectedCategory = "All"
                                    selectedTimeFilter = "All Time"
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                
                // Transaction List
                if filteredTransactions.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "creditcard.trianglebadge.exclamationmark" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "No transactions found" : "No results for '\(searchText)'")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "Add your first transaction to get started" : "Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if searchText.isEmpty {
                            Button("Add Transaction") {
                                showingAddTransaction = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.key) { group in
                            Section(group.key) {
                                ForEach(group.value, id: \.id) { transaction in
                                    TransactionRowView(transaction: transaction)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button("Delete") {
                                                deleteTransaction(transaction)
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.grouped)
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .searchable(text: $searchText, prompt: "Search transactions...")
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    // Group transactions by date
    private var groupedTransactions: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            guard let date = transaction.date else { return "Unknown" }
            
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        
        return grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            
            // For other dates, sort by the first transaction's date
            let firstDate = first.value.first?.date ?? Date.distantPast
            let secondDate = second.value.first?.date ?? Date.distantPast
            return firstDate > secondDate
        }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            viewContext.delete(transaction)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting transaction: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
