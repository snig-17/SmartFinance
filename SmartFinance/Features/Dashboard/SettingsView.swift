//
//  SettingsView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // User Preferences
    @AppStorage("selectedCurrency") private var selectedCurrency = "USD"
    @AppStorage("decimalPlaces") private var decimalPlaces = 2
    @AppStorage("defaultTransactionCategory") private var defaultTransactionCategory = "Other"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("budgetWarningsEnabled") private var budgetWarningsEnabled = true
    @AppStorage("securityNotificationsEnabled") private var securityNotificationsEnabled = true
    
    // App Info
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    private let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR"]
    private let categories = ["Food & Dining", "Transportation", "Shopping", "Entertainment", "Bills & Utilities", "Healthcare", "Travel", "Education", "Investment", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                // Security & Privacy Section
                Section {
                    NavigationLink(destination: BiometricSettingsView()) {
                        Label("Security & Privacy", systemImage: "lock.shield")
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text("Security")
                } footer: {
                    Text("Manage biometric authentication and privacy settings")
                }
                
                // Financial Preferences Section
                Section {
                    // Currency Selection
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Decimal Places
                    Stepper("Decimal Places: \(decimalPlaces)", value: $decimalPlaces, in: 0...4)
                    
                    // Default Category
                    Picker("Default Category", selection: $defaultTransactionCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                } header: {
                    Text("Financial Preferences")
                } footer: {
                    Text("Customize how financial data is displayed and categorized")
                }
                
                // Notifications Section
                Section {
                    Toggle("Transaction Notifications", isOn: $notificationsEnabled)
                    
                    Toggle("Budget Warnings", isOn: $budgetWarningsEnabled)
                        .disabled(!notificationsEnabled)
                    
                    Toggle("Security Alerts", isOn: $securityNotificationsEnabled)
                        .disabled(!notificationsEnabled)
                    
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Control which notifications you receive from SmartFinance")
                }
                
                // Data Management Section
                Section {
                    Button(action: exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: backupData) {
                        Label("Backup to iCloud", systemImage: "icloud.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: clearCache) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.orange)
                    }
                    
                    Button(role: .destructive, action: clearAllData) {
                        Label("Clear All Data", systemImage: "exclamationmark.triangle")
                    }
                    
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export, backup, or clear your financial data")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: openTermsOfService) {
                        Label("Terms of Service", systemImage: "doc.text")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: openPrivacyPolicy) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: contactSupport) {
                        Label("Contact Support", systemImage: "questionmark.circle")
                            .foregroundColor(.blue)
                    }
                    
                } header: {
                    Text("About")
                } footer: {
                    Text("SmartFinance - Your personal finance companion")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Action Methods
    
    private func exportData() {
        // Implement data export functionality
        print("Exporting data...")
        // You can implement CSV export or other formats here
    }
    
    private func backupData() {
        // Implement iCloud backup functionality
        print("Backing up to iCloud...")
        // Implement Core Data + CloudKit sync here
    }
    
    private func clearCache() {
        // Implement cache clearing
        print("Clearing cache...")
        // Clear any cached images, temporary files, etc.
    }
    
    private func clearAllData() {
        // Implement data clearing with confirmation
        print("Clearing all data...")
        // This should show an alert first, then clear Core Data
    }
    
    private func openTermsOfService() {
        // Open Terms of Service URL
        if let url = URL(string: "https://yourapp.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacyPolicy() {
        // Open Privacy Policy URL
        if let url = URL(string: "https://yourapp.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactSupport() {
        // Open support email or contact form
        if let url = URL(string: "mailto:support@yourapp.com?subject=SmartFinance Support") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
