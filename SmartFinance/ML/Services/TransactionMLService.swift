//
//  TransactionMLService.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import CoreML
import Foundation

class TransactionMLService: ObservableObject {
    private var model: MLModel?
    @Published var isModelLoaded = false
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        // Try to load the ML model, fallback to rules if it fails
        do {
            if let modelURL = Bundle.main.url(forResource: "TransactionCategorizer", withExtension: "mlmodel") {
                model = try MLModel(contentsOf: modelURL)
                isModelLoaded = true
                print("✅ ML Model loaded successfully!")
            }
        } catch {
            print("⚠️ ML Model not found, using rule-based categorization")
            isModelLoaded = false
        }
    }
    
    func predictCategory(for description: String) -> String {
        // If ML model is available, try to use it
        if let model = model {
            do {
                let input = try MLDictionaryFeatureProvider(dictionary: ["text": description])
                let prediction = try model.prediction(from: input)
                
                if let category = prediction.featureValue(for: "label")?.stringValue {
                    return category
                }
            } catch {
                print("❌ ML prediction failed: \(error)")
            }
        }
        
        // Fallback to rule-based categorization
        return ruleBasedCategorization(description)
    }
    
    private func ruleBasedCategorization(_ merchant: String) -> String {
        let merchantLower = merchant.lowercased()
        
        // Food & Dining
        if merchantLower.contains("starbucks") || merchantLower.contains("mcdonald") ||
           merchantLower.contains("restaurant") || merchantLower.contains("coffee") ||
           merchantLower.contains("pizza") || merchantLower.contains("burger") ||
           merchantLower.contains("chipotle") || merchantLower.contains("subway") {
            return "Food & Dining"
        }
        
        // Groceries
        if merchantLower.contains("whole foods") || merchantLower.contains("safeway") ||
           merchantLower.contains("trader joe") || merchantLower.contains("costco") ||
           merchantLower.contains("walmart") && merchantLower.contains("grocery") ||
           merchantLower.contains("market") && !merchantLower.contains("stock") {
            return "Groceries"
        }
        
        // Transportation
        if merchantLower.contains("shell") || merchantLower.contains("chevron") ||
           merchantLower.contains("uber") || merchantLower.contains("lyft") ||
           merchantLower.contains("gas") || merchantLower.contains("parking") ||
           merchantLower.contains("taxi") || merchantLower.contains("bus") {
            return "Transportation"
        }
        
        // Shopping
        if merchantLower.contains("amazon") || merchantLower.contains("target") ||
           merchantLower.contains("walmart") || merchantLower.contains("store") ||
           merchantLower.contains("shop") || merchantLower.contains("retail") {
            return "Shopping"
        }
        
        // Electronics
        if merchantLower.contains("apple store") || merchantLower.contains("best buy") ||
           merchantLower.contains("electronics") || merchantLower.contains("computer") {
            return "Electronics"
        }
        
        // Entertainment
        if merchantLower.contains("netflix") || merchantLower.contains("spotify") ||
           merchantLower.contains("theater") || merchantLower.contains("movie") ||
           merchantLower.contains("game") || merchantLower.contains("steam") {
            return "Entertainment"
        }
        
        // Healthcare
        if merchantLower.contains("cvs") || merchantLower.contains("pharmacy") ||
           merchantLower.contains("doctor") || merchantLower.contains("medical") ||
           merchantLower.contains("hospital") || merchantLower.contains("dental") {
            return "Healthcare"
        }
        
        // Banking
        if merchantLower.contains("atm") || merchantLower.contains("bank") ||
           merchantLower.contains("fee") || merchantLower.contains("withdrawal") {
            return "Banking"
        }
        
        // Utilities
        if merchantLower.contains("electric") || merchantLower.contains("gas") && merchantLower.contains("company") ||
           merchantLower.contains("internet") || merchantLower.contains("phone") ||
           merchantLower.contains("cable") || merchantLower.contains("utility") {
            return "Utilities"
        }
        
        // Transfer
        if merchantLower.contains("venmo") || merchantLower.contains("zelle") ||
           merchantLower.contains("paypal") || merchantLower.contains("transfer") {
            return "Transfer"
        }
        
        return "Other"
    }
}
