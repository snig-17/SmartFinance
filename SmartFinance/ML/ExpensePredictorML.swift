////
////  ExpensePredictorML.swift
////  SmartFinance
////
////  Created by Snigdha Tiwari  on 08/08/2025.
////
//
//import Foundation
//import CreateMLComponents
//import CoreML
//
//class ExpensePredictorML: ObservableObject {
//    @Published var predictedMonthlySpending: Double = 0
//    @Published var budgetRecommendations: [String: Double] = [:]
//    
//    func trainPredictionModel() {
//        // Train model using user's historical data
//        let trainingData = prepareTrainingData()
//        
//        do {
//            let regressor = try MLRegressor(trainingData: trainingData,
//                                          targetColumn: "amount")
//            try regressor.write(to: modelURL)
//        } catch {
//            print("Training failed: \(error)")
//        }
//    }
//    
//    func predictFutureSpending(for category: String, days: Int) -> Double {
//        // Predict spending based on historical patterns
//        guard let model = loadModel() else { return 0 }
//        
//        let prediction = try? model.prediction(from: [
//            "category": category,
//            "days_ahead": days,
//            "historical_average": calculateHistoricalAverage(category)
//        ])
//        
//        return prediction?.amount ?? 0
//    }
//}
