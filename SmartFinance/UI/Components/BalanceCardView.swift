//
//  BalanceCardView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import SwiftUI

struct BalanceCardView: View {
    let balance: NSDecimalNumber
    let monthlySpending: NSDecimalNumber
    let isLoading: Bool
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: balance) ?? "$0.00"
    }
    
    private var formattedSpending: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: monthlySpending) ?? "$0.00"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Main balance display
            VStack(spacing: 8) {
                HStack {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
                
                HStack {
                    Text(formattedBalance)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.6), value: balance)
                    
                    Spacer()
                }
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Monthly spending summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(formattedSpending)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Spending change indicator
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                    Text("+12%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .background {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

// Preview
struct BalanceCardView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceCardView(
            balance: NSDecimalNumber(value: 2485.50),
            monthlySpending: NSDecimalNumber(value: 1250.75),
            isLoading: false
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
