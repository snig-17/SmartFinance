//
//  TransactionRowView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari on 08/08/2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: transaction.categoryIcon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayMerchant)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(transaction.displayCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount and Date
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(transaction.relativeDateString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// Preview
struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleTransaction = Transaction.createSample(in: context)
        
        TransactionRowView(transaction: sampleTransaction)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
