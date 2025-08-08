////
////  RecieptScannerML.swift
////  SmartFinance
////
////  Created by Snigdha Tiwari  on 08/08/2025.
////
//
//import Foundation
//import Vision
//import VisionKit
//import CoreML
//
//class ReceiptScannerML: NSObject, ObservableObject {
//    @Published var extractedTransaction: Transaction?
//    @Published var isProcessing = false
//    
//    func processReceipt(_ image: UIImage) {
//        isProcessing = true
//        
//        // Step 1: OCR Text Recognition
//        performTextRecognition(on: image) { [weak self] texts in
//            // Step 2: ML-powered information extraction
//            self?.extractTransactionInfo(from: texts)
//        }
//    }
//    
//    private func extractTransactionInfo(from texts: [String]) {
//        let processor = ReceiptInfoExtractor()
//        
//        // Use NLP to extract structured data
//        let merchant = processor.extractMerchant(texts)
//        let amount = processor.extractAmount(texts)
//        let date = processor.extractDate(texts)
//        let category = TransactionCategorizerML().predictCategory(
//            for: merchant,
//            amount: amount
//        )
//        
//        DispatchQueue.main.async {
//            self.extractedTransaction = Transaction(
//                merchant: merchant,
//                amount: NSDecimalNumber(value: amount),
//                category: category,
//                date: date
//            )
//            self.isProcessing = false
//        }
//    }
//}
