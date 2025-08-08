////
////  FraudDetectionML.swift
////  SmartFinance
////
////  Created by Snigdha Tiwari  on 08/08/2025.
////
//
//import Foundation
//import CoreML
//import Accelerate
//
//class FraudDetectionML: ObservableObject {
//    @Published var suspiciousTransactions: [Transaction] = []
//    
//    func analyzeTransaction(_ transaction: Transaction) -> FraudRisk {
//        let features = [
//            transaction.amount.doubleValue,
//            timeOfDayFeature(transaction.date),
//            merchantFrequencyScore(transaction.merchant),
//            locationAnomalyScore(transaction),
//            amountAnomalyScore(transaction.amount.doubleValue)
//        ]
//        
//        let riskScore = calculateAnomalyScore(features)
//        return classifyRisk(score: riskScore)
//    }
//    
//    private func calculateAnomalyScore(_ features: [Double]) -> Double {
//        // Isolation Forest or One-Class SVM implementation
//        // Using statistical methods for anomaly detection
//        let mean = features.reduce(0, +) / Double(features.count)
//        let variance = features.map { pow($0 - mean, 2) }.reduce(0, +) / Double(features.count)
//        
//        return sqrt(variance) // Simplified anomaly score
//    }
//}
