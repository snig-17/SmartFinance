////
////  CashFlowPredictorML.swift
////  SmartFinance
////
////  Created by Snigdha Tiwari  on 08/08/2025.
////
//
//import Foundation
//import CoreML
//import Charts
//
//class CashFlowPredictorML: ObservableObject {
//    @Published var cashFlowForecast: [CashFlowPrediction] = []
//    @Published var lowBalanceAlerts: [BalanceAlert] = []
//    
//    func generateCashFlowForecast(days: Int = 30) {
//        let historicalData = prepareTimeSeriesData()
//        
//        // Time series forecasting using ARIMA or LSTM-like approach
//        let predictions = performTimeSeriesForecasting(
//            data: historicalData,
//            forecastDays: days
//        )
//        
//        cashFlowForecast = predictions.map { prediction in
//            CashFlowPrediction(
//                date: prediction.date,
//                predictedBalance: prediction.balance,
//                confidence: prediction.confidence,
//                factors: prediction.contributingFactors
//            )
//        }
//        
//        // Generate proactive alerts
//        generateBalanceAlerts()
//    }
//    
//    private func generateBalanceAlerts() {
//        let criticalDates = cashFlowForecast.filter { $0.predictedBalance < 100 }
//        
//        lowBalanceAlerts = criticalDates.map { prediction in
//            BalanceAlert(
//                date: prediction.date,
//                predictedBalance: prediction.predictedBalance,
//                severity: prediction.predictedBalance < 0 ? .critical : .warning,
//                recommendation: generateRecommendation(for: prediction)
//            )
//        }
//    }
//}
