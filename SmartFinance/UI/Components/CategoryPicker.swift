//
//  CategoryPicker.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import Foundation
import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: String
    
    private let categories = [
        "Food & Dining",
        "Groceries",
        "Transportation",
        "Shopping",
        "Electronics",
        "Entertainment",
        "Healthcare",
        "Banking",
        "Utilities",
        "Transfer",
        "Insurance",
        "Other"
    ]
    
    var body: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(categories, id: \.self) { category in
                Text(category).tag(category)
            }
        }
        .pickerStyle(.menu)
    }
}
