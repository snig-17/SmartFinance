//
//  ContentView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Balance Overview Card
                    BalanceCardView(
                        balance: viewModel.currentBalance,
                        monthlySpending: viewModel.monthlySpending,
                        isLoading: viewModel.isLoading
                    )
                    
                    // Recent Transactions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("See All") {
                                // Navigate to full transaction list - implement later
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if viewModel.transactions.isEmpty {
                            // Empty state
                            VStack(spacing: 12) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No transactions yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add your first transaction to get started")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Add Sample Transaction") {
                                    viewModel.addSampleTransaction()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            // Transaction List
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.transactions, id: \.id) { transaction in
                                    TransactionRowView(transaction: transaction)
                                    
                                    if transaction != viewModel.transactions.last {
                                        Divider()
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    // Quick Stats Section
                    QuickStatsView(viewModel: viewModel)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("SmartFinance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.addSampleTransaction()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        // Profile/Settings - implement later
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                // Transaction Count
                StatCardView(
                    title: "Transactions",
                    value: "\(viewModel.transactions.count)",
                    icon: "creditcard",
                    color: .blue
                )
                
                // Average Transaction
                StatCardView(
                    title: "Average",
                    value: viewModel.averageTransactionAmount,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                // This Month
                StatCardView(
                    title: "This Month",
                    value: viewModel.monthlySpendingFormatted,
                    icon: "calendar",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Stat Card View
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
