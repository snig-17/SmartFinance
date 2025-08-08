//
//  PaymentMethod.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import Foundation

enum PaymentMethod: String, CaseIterable {
    case card = "Card"
    case cash = "Cash"
    case applePay = "Apple Pay"
    case bankTransfer = "Bank Transfer"
    
    var icon: String {
        switch self {
        case .card: return "creditcard"
        case .cash: return "banknote"
        case .applePay: return "apple.logo"
        case .bankTransfer: return "building.columns"
        }
    }
}
