//
//  AddTransactionView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var merchant = ""
    @State private var selectedCategory = "Other"
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var notes = ""
    @State private var date = Date()
    
    // Simple suggestion state
    @State private var suggestedCategory = ""
    @State private var showSuggestion = false
    
    // Receipt scanner state
    @State private var showingReceiptScanner = false
    @State private var scannedReceipt: ScannedReceipt?
    
    var body: some View {
        NavigationView {
            Form {
                // Amount Section
                Section("Amount") {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.green)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                        
                        Spacer()
                        
                        // Receipt Scanner Button
                        Button(action: {
                            showingReceiptScanner = true
                        }) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Merchant Section
                Section("Merchant") {
                    TextField("Where did you spend?", text: $merchant)
                        .onChange(of: merchant) { newValue in
                            updateSuggestion(for: newValue)
                        }
                    
                    // Simple suggestion
                    if showSuggestion && !suggestedCategory.isEmpty {
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("Suggestion")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(suggestedCategory)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            Spacer()
                            Button("Use") {
                                selectedCategory = suggestedCategory
                                showSuggestion = false
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Category Section
                Section("Category") {
                    CategoryPicker(selectedCategory: $selectedCategory)
                }
                
                // Payment Method Section
                Section("Payment Method") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Button(action: {
                                selectedPaymentMethod = method
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: method.icon)
                                        .font(.system(size: 16))
                                    Text(method.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPaymentMethod == method ?
                                              Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedPaymentMethod == method ?
                                                Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Date Section
                Section("Date") {
                    DatePicker("Transaction Date", selection: $date, displayedComponents: .date)
                }
                
                // Notes Section
                Section("Notes (Optional)") {
                    TextField("Add notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Save Button
                Section {
                    Button("Add Transaction") {
                        saveTransaction()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(amount.isEmpty || merchant.isEmpty)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Sheet presentation moved to correct location
            .sheet(isPresented: $showingReceiptScanner) {
                ReceiptScannerView(onReceiptScanned: { receipt in
                    handleScannedReceipt(receipt)
                })
            }
        }
    }
    
    // Function moved outside of body - FIXED
    private func handleScannedReceipt(_ receipt: ScannedReceipt) {
        scannedReceipt = receipt
        
        // Auto-fill form with scanned data
        if let merchantName = receipt.merchant {
            merchant = merchantName
        }
        
        if let scannedAmount = receipt.amount {
            amount = String(format: "%.2f", scannedAmount)
        }
        
        if let category = receipt.category {
            selectedCategory = category
        }
        
        if let scannedDate = receipt.date {
            date = scannedDate
        }
        
        // Show confidence indicator
        if receipt.isHighConfidence {
            print("✅ Receipt scanned successfully!")
        } else {
            print("⚠️ Low confidence scan - please verify details")
        }
    }
    
    // Simple function for suggestions
    private func updateSuggestion(for merchant: String) {
        let merchantLower = merchant.lowercased()
        var suggestion = ""
        
        // Simple rule-based suggestions
        if merchantLower.contains("starbucks") || merchantLower.contains("mcdonald") || merchantLower.contains("restaurant") {
            suggestion = "Food & Dining"
        } else if merchantLower.contains("amazon") || merchantLower.contains("target") || merchantLower.contains("walmart") {
            suggestion = "Shopping"
        } else if merchantLower.contains("shell") || merchantLower.contains("chevron") || merchantLower.contains("gas") {
            suggestion = "Transportation"
        } else if merchantLower.contains("netflix") || merchantLower.contains("spotify") || merchantLower.contains("apple music") {
            suggestion = "Entertainment"
        } else if merchantLower.contains("whole foods") || merchantLower.contains("safeway") || merchantLower.contains("grocery") {
            suggestion = "Groceries"
        } else if merchantLower.contains("cvs") || merchantLower.contains("pharmacy") || merchantLower.contains("doctor") {
            suggestion = "Healthcare"
        }
        
        // Update suggestion state
        if !suggestion.isEmpty && suggestion != selectedCategory && merchant.count > 2 {
            suggestedCategory = suggestion
            showSuggestion = true
        } else {
            showSuggestion = false
        }
    }
    
    private func saveTransaction() {
        // Safe unwrapping, no force unwrap
        guard let amountValue = Double(amount), amountValue > 0 else {
            print("❌ Invalid amount")
            return
        }
        
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(value: amountValue)
        transaction.merchant = merchant
        transaction.category = selectedCategory
        transaction.paymentMethod = selectedPaymentMethod.rawValue
        transaction.notes = notes.isEmpty ? nil : notes
        transaction.date = date
        
        do {
            try viewContext.save()
            print("✅ Transaction saved: \(merchant) - $\(amountValue)")
            dismiss()
        } catch {
            print("❌ Failed to save transaction: \(error)")
        }
    }
}

// Preview
#Preview {
    AddTransactionView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
