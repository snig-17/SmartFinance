//
//  ReceiptScannerService.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import Vision
import UIKit
import Foundation

class ReceiptScannerService: ObservableObject {
    @Published var scannedReceipt: ScannedReceipt?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    func scanReceipt(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(false)
            return
        }
        
        isProcessing = true
        
        // Create Vision request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            self?.processVisionResults(request.results, completion: completion)
        }
        
        // Configure for receipt scanning
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        
        // Perform OCR
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to scan receipt: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    private func processVisionResults(_ results: [Any]?, completion: @escaping (Bool) -> Void) {
        guard let observations = results as? [VNRecognizedTextObservation] else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        // Extract all text from receipt
        var allText: [String] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            allText.append(topCandidate.string)
        }
        
        // Parse receipt data
        let parser = ReceiptParser()
        let parsedReceipt = parser.parseReceipt(from: allText)
        
        DispatchQueue.main.async {
            self.isProcessing = false
            self.scannedReceipt = parsedReceipt
            completion(true)
        }
    }
}

// MARK: - Receipt Data Models
struct ScannedReceipt: Equatable {
    let merchant: String?
    let amount: Double?
    let date: Date?
    let category: String?
    let confidence: ReceiptConfidence
    let rawText: [String]
    
    var isHighConfidence: Bool {
        return confidence.overall >= 0.7
    }
    
    // Implement Equatable
    static func == (lhs: ScannedReceipt, rhs: ScannedReceipt) -> Bool {
        return lhs.merchant == rhs.merchant &&
               lhs.amount == rhs.amount &&
               lhs.date == rhs.date &&
               lhs.category == rhs.category &&
               lhs.confidence == rhs.confidence &&
               lhs.rawText == rhs.rawText
    }
}

struct ReceiptConfidence: Equatable {
    let merchant: Double
    let amount: Double
    let date: Double
    let overall: Double
    
    init(merchant: Double, amount: Double, date: Double) {
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.overall = (merchant + amount + date) / 3.0
    }
    
    // Implement Equatable
    static func == (lhs: ReceiptConfidence, rhs: ReceiptConfidence) -> Bool {
        return lhs.merchant == rhs.merchant &&
               lhs.amount == rhs.amount &&
               lhs.date == rhs.date &&
               lhs.overall == rhs.overall
    }
}

// MARK: - Receipt Parser
class ReceiptParser {
    
    func parseReceipt(from textLines: [String]) -> ScannedReceipt {
        let merchant = extractMerchant(from: textLines)
        let amount = extractAmount(from: textLines)
        let date = extractDate(from: textLines)
        let category = categorizeFromMerchant(merchant?.name)
        
        let confidence = ReceiptConfidence(
            merchant: merchant?.confidence ?? 0.0,
            amount: amount?.confidence ?? 0.0,
            date: date?.confidence ?? 0.0
        )
        
        return ScannedReceipt(
            merchant: merchant?.name,
            amount: amount?.value,
            date: date?.value,
            category: category,
            confidence: confidence,
            rawText: textLines
        )
    }
    
    // MARK: - Merchant Extraction
    private func extractMerchant(from lines: [String]) -> (name: String, confidence: Double)? {
        // Look for merchant patterns in first few lines
        let merchantPatterns = [
            // Common chain stores
            #"(STARBUCKS|MCDONALD'?S|WALMART|TARGET|AMAZON|COSTCO|SAFEWAY|CVS|WALGREENS)"#,
            // Generic business patterns
            #"^[A-Z][A-Z\s&]{2,30}(?=\s|$)"#,
            // Store with location
            #"^([A-Z][A-Z\s&]{2,20})\s+#?\d+"#
        ]
        
        // Check first 5 lines (merchant usually at top)
        let topLines = Array(lines.prefix(5))
        
        for (index, line) in topLines.enumerated() {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            for pattern in merchantPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(cleanLine.startIndex..<cleanLine.endIndex, in: cleanLine)
                    
                    if let match = regex.firstMatch(in: cleanLine, options: [], range: range) {
                        // FIXED: Safe range conversion
                        if let swiftRange = Range(match.range, in: cleanLine) {
                            let merchantName = String(cleanLine[swiftRange])
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Confidence based on position and pattern match
                            let confidence = 0.9 - (Double(index) * 0.1)
                            
                            if merchantName.count >= 3 {
                                return (merchantName, confidence)
                            }
                        }
                    }
                }
            }
        }
        
        // Fallback: first non-empty line that looks like a business name
        for line in topLines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanLine.count > 3 && cleanLine.count < 50 &&
               cleanLine.rangeOfCharacter(from: .decimalDigits) == nil {
                return (cleanLine, 0.5)
            }
        }
        
        return nil
    }
    
    // MARK: - Amount Extraction (FIXED)
    private func extractAmount(from lines: [String]) -> (value: Double, confidence: Double)? {
        let amountPatterns = [
            // Total patterns (highest confidence)
            #"(?i)total.*?[\$]?([\d,]+\.?\d{0,2})"#,
            #"(?i)amount.*?[\$]?([\d,]+\.?\d{0,2})"#,
            #"(?i)subtotal.*?[\$]?([\d,]+\.?\d{0,2})"#,
            // Generic dollar amounts
            #"[\$]([\d,]+\.?\d{0,2})"#,
            // Amount without dollar sign (lower confidence)
            #"\b([\d,]+\.\d{2})\b"#
        ]
        
        var foundAmounts: [(amount: Double, confidence: Double)] = []
        
        // Check all lines, prioritizing those with "total" keywords
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            for (patternIndex, pattern) in amountPatterns.enumerated() {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(cleanLine.startIndex..<cleanLine.endIndex, in: cleanLine)
                    let matches = regex.matches(in: cleanLine, options: [], range: range)
                    
                    for match in matches {
                        if match.numberOfRanges > 1 {
                            let amountRange = match.range(at: 1)
                            if let swiftRange = Range(amountRange, in: cleanLine) {
                                let amountString = String(cleanLine[swiftRange])
                                    .replacingOccurrences(of: ",", with: "")
                                
                                if let amount = Double(amountString), amount > 0 && amount < 10000 {
                                    // Higher confidence for "total" patterns
                                    let confidence = patternIndex == 0 ? 0.9 :
                                                   patternIndex <= 2 ? 0.8 :
                                                   patternIndex == 3 ? 0.7 : 0.5
                                    
                                    foundAmounts.append((amount, confidence))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // FIXED: Return highest confidence amount properly
        if let maxAmount = foundAmounts.max(by: { $0.confidence < $1.confidence }) {
            return (maxAmount.amount, maxAmount.confidence)
        }
        return nil
    }
    
    // MARK: - Date Extraction (FIXED)
    private func extractDate(from lines: [String]) -> (value: Date, confidence: Double)? {
        let datePatterns = [
            #"\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b"#,  // MM/DD/YYYY
            #"\b(\d{2,4})[\/\-](\d{1,2})[\/\-](\d{1,2})\b"#,  // YYYY/MM/DD
            #"\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2}),?\s+(\d{2,4})"# // Jan 15, 2024
        ]
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            for pattern in datePatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(cleanLine.startIndex..<cleanLine.endIndex, in: cleanLine)
                    
                    if let match = regex.firstMatch(in: cleanLine, options: [], range: range) {
                        // FIXED: Safe range conversion
                        if let swiftRange = Range(match.range, in: cleanLine) {
                            let dateString = String(cleanLine[swiftRange])
                            
                            if let date = parseDate(from: dateString) {
                                return (date, 0.8)
                            }
                        }
                    }
                }
            }
        }
        
        // Fallback to today's date
        return (Date(), 0.3)
    }
    
    private func parseDate(from dateString: String) -> Date? {
        let dateFormatters = [
            "MM/dd/yyyy", "MM/dd/yy", "M/d/yyyy", "M/d/yy",
            "yyyy/MM/dd", "yyyy/M/d",
            "MMM dd, yyyy", "MMM d, yyyy"
        ]
        
        for format in dateFormatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US")
            
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Category Detection
    private func categorizeFromMerchant(_ merchantName: String?) -> String? {
        guard let merchant = merchantName?.lowercased() else { return nil }
        
        if merchant.contains("starbucks") || merchant.contains("mcdonald") ||
           merchant.contains("restaurant") || merchant.contains("cafe") {
            return "Food & Dining"
        } else if merchant.contains("walmart") || merchant.contains("target") ||
                  merchant.contains("amazon") || merchant.contains("store") {
            return "Shopping"
        } else if merchant.contains("shell") || merchant.contains("chevron") ||
                  merchant.contains("gas") || merchant.contains("fuel") {
            return "Transportation"
        } else if merchant.contains("cvs") || merchant.contains("pharmacy") ||
                  merchant.contains("walgreens") || merchant.contains("medical") {
            return "Healthcare"
        } else if merchant.contains("safeway") || merchant.contains("costco") ||
                  merchant.contains("market") || merchant.contains("grocery") {
            return "Groceries"
        }
        
        return nil
    }
}
