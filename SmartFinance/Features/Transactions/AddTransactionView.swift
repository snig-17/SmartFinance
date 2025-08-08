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
    
    //form fields
    @State private var amount: String = ""
    @State private var merchant: String = ""
    @State private var selectedCategory: String = "Food & Dining"
    @State private var selectedPaymentMethod: String = "Card"
    @State private var notes: String = ""
    @State private var transactionDate = Date()
    @State private var isRecurring = false
    
    //form state
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    //available options
    private let categories = [
        "Food & Dining", "Groceries", "Shopping", "Transportation",
        "Gas & Fuel", "Entertainment", "Technology", "Healthcare",
        "Bills & Utilities", "Education", "Fitness", "Beauty", "Other"
    ]
    private let paymentMethods = ["Card", "Cash", "Apple Pay", "Bank Transfer"]

    
    var body: some View {
        NavigationStack{
            Form{
                //amount section
                Section("Transaction Details"){
                    HStack{
                        Image(systemName: "dollarsign.circle.fill").foregroundColor(.green)
                            .font(.title2)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    HStack{
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.blue)
                        TextField("Merchant Name", text: $merchant)
                    }
                    
                    DatePicker(
                        "Date",
                        selection: $transactionDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                
                // category section
                Section("Category"){
                    Picker("Category", selection: $selectedCategory){
                        ForEach(categories, id: \.self) { category in
                            HStack {
                                Image(systemName: iconForCategory(category))
                                    .foregroundColor(colorForCategory(category))
                                Text(category)
                            }
                            .tag(category)
                        }
                        
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // payment method section
                Section("Payment Method") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(paymentMethods, id: \.self) { method in
                            Button {
                                selectedPaymentMethod = method
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: iconForPaymentMethod(method))
                                        .font(.title3)
                                        .foregroundColor(.purple)
                                    
                                    Text(method)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedPaymentMethod == method ? Color.purple.opacity(0.1) : Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedPaymentMethod == method ? Color.purple : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // additional options
                Section("Additional Options"){
                    HStack{
                        Image(systemName: "repeat")
                            .foregroundColor(.orange)
                        Toggle("Recurring Transaction", isOn: $isRecurring)
                    }
                    HStack(alignment: .top){
                        Image(systemName: "note.text")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                // preview section
                if !amount.isEmpty && !merchant.isEmpty {
                    Section("Preview"){
                        TransactionPreviewRow(
                            amount:amount,
                            merchant: merchant,
                            category: selectedCategory,
                            paymentMethod: selectedPaymentMethod,
                            date: transactionDate,
                            isRecurring: isRecurring
                        )
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Save"){
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert("Error", isPresented: $showingAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                setupInitialData()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !amount.isEmpty &&
        !merchant.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    // MARK: - Methods
    
    private func setupInitialData(){
        transactionDate = Date()
    }
    private func saveTransaction(){
        guard let amountValue = Double(amount), amountValue > 0 else{
            showError("Please enter a valid amount")
            return
        }
        
        guard !merchant.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else {
            showError("Please enter a merchant name")
            return
        }
        
        isLoading = true
        
        // create new transaction
        let transaction = Transaction.create(in: viewContext, amount: Decimal(amountValue), merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines),
                                             category: selectedCategory, currency: "USD", paymentMethod: selectedPaymentMethod, notes: notes.isEmpty ? nil:notes)
        transaction.date = transactionDate
        transaction.isRecurring = isRecurring
        
        // save to core data
        do {
            try viewContext.save()
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            dismiss()
        } catch {
            showError("Failed to save transaction: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    // MARK: - Helper Methods
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "food & dining": return "fork.knife"
        case "groceries": return "cart"
        case "shopping": return "bag"
        case "transportation": return "car"
        case "gas & fuel": return "fuelpump"
        case "entertainment": return "tv"
        case "technology": return "laptopcomputer"
        case "healthcare": return "cross.case"
        case "bills & utilities": return "house"
        case "education": return "book"
        case "fitness": return "figure.run"
        case "beauty": return "scissors"
        default: return "questionmark.circle"
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "food & dining": return .orange
        case "groceries": return .green
        case "shopping": return .purple
        case "transportation": return .blue
        case "gas & fuel": return .red
        case "entertainment": return .pink
        case "technology": return .gray
        case "healthcare": return .red
        case "bills & utilities": return .yellow
        default: return .gray
        }
    }
    private func iconForPaymentMethod(_ method: String) -> String {
        switch method.lowercased() {
        case "card": return "creditcard"
        case "cash": return "banknote"
        case "apple pay": return "wave.3.right"
        case "bank transfer": return "building.columns"
        default: return "questionmark"
        }
    }

}

// MARK: - Transaction Preview Row

struct TransactionPreviewRow: View {
    let amount: String
    let merchant: String
    let category: String
    let paymentMethod: String
    let date: Date
    let isRecurring: Bool
    
    var body: some View {
        HStack(spacing: 16) {
                    // Category Icon
                    Image(systemName: iconForCategory(category))
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
            // Transaction Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(merchant)
                                .font(.headline)
                                .foregroundColor(.primary)
                            HStack {
                                               Text(category)
                                                   .font(.caption)
                                                   .foregroundColor(.secondary)
                                               
                                               if isRecurring {
                                                   Image(systemName: "repeat")
                                                       .font(.caption2)
                                                       .foregroundColor(.orange)
                                               }
                                           }
                                       }
            Spacer()
            // Amount and Date
                        VStack(alignment: .trailing, spacing: 4) {
                            if let amountValue = Double(amount) {
                                Text("$\(amountValue, specifier: "%.2f")")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            } else {
                                Text("$\(amount)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Text(date, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                private func iconForCategory(_ category: String) -> String {
                    switch category.lowercased() {
                    case "food & dining": return "fork.knife"
                    case "groceries": return "cart"
                    case "shopping": return "bag"
                    case "transportation": return "car"
                    case "gas & fuel": return "fuelpump"
                    case "entertainment": return "tv"
                    case "technology": return "laptopcomputer"
                    case "healthcare": return "cross.case"
                    case "bills & utilities": return "house"
                    case "education": return "book"
                    case "fitness": return "figure.run"
                    case "beauty": return "scissors"
                    default: return "questionmark.circle"
                    }
                }
            }



#Preview {
    NavigationStack{
        
        AddTransactionView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
