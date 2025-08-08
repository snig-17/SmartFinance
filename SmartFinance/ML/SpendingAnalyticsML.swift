////
////  SpendingAnalyticsML.swift
////  SmartFinance
////
////  Created by Snigdha Tiwari  on 08/08/2025.
////
//
//import Foundation
//import CoreML
//import Accelerate
//
//class SpendingAnalyticsML: ObservableObject {
//    @Published var spendingPersona: SpendingPersona = .balanced
//    @Published var insights: [SpendingInsight] = []
//    
//    func analyzeSpendingPatterns() {
//        let transactions = fetchAllTransactions()
//        let features = extractBehavioralFeatures(transactions)
//        
//        // K-means clustering for spending personas
//        let clusters = performClustering(features)
//        spendingPersona = determinePersona(from: clusters)
//        
//        // Generate actionable insights
//        insights = generateInsights(from: features, persona: spendingPersona)
//    }
//    
//    private func generateInsights(from features: [SpendingFeature],
//                                 persona: SpendingPersona) -> [SpendingInsight] {
//        var insights: [SpendingInsight] = []
//        
//        // ML-generated insights
//        if features.weekendSpendingRatio > 0.6 {
//            insights.append(.weekendSpender(
//                recommendation: "Consider setting weekend spending limits"
//            ))
//        }
//        
//        if features.impulseBuyingScore > 0.7 {
//            insights.append(.impulseBuyer(
//                recommendation: "Try the 24-hour rule before purchases over $50"
//            ))
//        }
//        
//        return insights
//    }
//}
//
//enum SpendingPersona {
//    case conservative, balanced, spender, investor
//    
//    var description: String {
//        switch self {
//        case .conservative: return "Careful Saver"
//        case .balanced: return "Balanced Spender"
//        case .spender: return "Lifestyle Focused"
//        case .investor: return "Growth Oriented"
//        }
//    }
//}
