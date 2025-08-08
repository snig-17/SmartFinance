//
//  BiometricManager.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import Foundation
import LocalAuthentication
import Foundation

class BiometricManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    @Published var isLoading = false
    
    private let context = LAContext()
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .touchID: return "Touch ID"
            case .faceID: return "Face ID"
            case .opticID: return "Optic ID"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return "lock"
            case .touchID: return "touchid"
            case .faceID: return "faceid"
            case .opticID: return "opticid"
            }
        }
    }
    
    enum AuthenticationState {
        case notDetermined
        case available
        case notAvailable
        case lockedOut
        case notEnrolled
    }
    
    // MARK: - Biometric Availability
    func getBiometricType() -> BiometricType {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }
    
    func getAuthenticationState() -> AuthenticationState {
        var error: NSError?
        
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canEvaluate {
            return .available
        }
        
        guard let error = error else {
            return .notDetermined
        }
        
        switch error.code {
        case LAError.biometryNotEnrolled.rawValue:
            return .notEnrolled
        case LAError.biometryLockout.rawValue:
            return .lockedOut
        default:
            return .notAvailable
        }
    }
    
    // MARK: - Authentication Methods
    func authenticateWithBiometrics(reason: String = "Access your financial data securely") async -> Bool {
        await MainActor.run {
            isLoading = true
            authenticationError = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Check if biometrics are available
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            await MainActor.run {
                authenticationError = error?.localizedDescription ?? "Biometric authentication not available"
            }
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                isAuthenticated = success
            }
            
            if success {
                // Store authentication timestamp
                UserDefaults.standard.set(Date(), forKey: "lastAuthenticationTime")
                print("✅ Biometric authentication successful")
            }
            
            return success
            
        } catch let error as LAError {
            await handleAuthenticationError(error)
            return false
        } catch {
            await MainActor.run {
                authenticationError = "Authentication failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func authenticateWithPasscode(reason: String = "Enter your device passcode to access SmartFinance") async -> Bool {
        await MainActor.run {
            isLoading = true
            authenticationError = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            
            await MainActor.run {
                isAuthenticated = success
            }
            
            if success {
                UserDefaults.standard.set(Date(), forKey: "lastAuthenticationTime")
                print("✅ Passcode authentication successful")
            }
            
            return success
            
        } catch let error as LAError {
            await handleAuthenticationError(error)
            return false
        } catch {
            await MainActor.run {
                authenticationError = "Authentication failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Error Handling
    @MainActor
    private func handleAuthenticationError(_ error: LAError) {
        switch error.code {
        case .authenticationFailed:
            authenticationError = "Authentication failed. Please try again."
        case .userCancel:
            authenticationError = "Authentication was cancelled."
        case .userFallback:
            authenticationError = "User chose to enter password."
        case .systemCancel:
            authenticationError = "Authentication was cancelled by the system."
        case .passcodeNotSet:
            authenticationError = "Passcode is not set on the device."
        case .biometryNotAvailable:
            authenticationError = "Biometric authentication is not available."
        case .biometryNotEnrolled:
            authenticationError = "Biometric authentication is not set up."
        case .biometryLockout:
            authenticationError = "Biometric authentication is locked. Use passcode to unlock."
        case .appCancel:
            authenticationError = "Authentication was cancelled by the app."
        case .invalidContext:
            authenticationError = "Authentication context is invalid."
        case .notInteractive:
            authenticationError = "Authentication is not interactive."
        default:
            authenticationError = "Authentication error: \(error.localizedDescription)"
        }
        
        print("❌ Authentication error: \(authenticationError ?? "Unknown")")
    }
    
    // MARK: - Session Management
    func shouldRequireAuthentication() -> Bool {
        // Check if user has enabled biometric authentication
        guard UserDefaults.standard.bool(forKey: "biometricAuthEnabled") else {
            return false
        }
        
        // Check last authentication time
        guard let lastAuth = UserDefaults.standard.object(forKey: "lastAuthenticationTime") as? Date else {
            return true
        }
        
        // Require re-authentication after 5 minutes of inactivity
        let sessionTimeout: TimeInterval = 5 * 60 // 5 minutes
        return Date().timeIntervalSince(lastAuth) > sessionTimeout
    }
    
    func logout() {
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "lastAuthenticationTime")
        print("🔐 User logged out")
    }
    
    // MARK: - Settings
    func enableBiometricAuth() {
        UserDefaults.standard.set(true, forKey: "biometricAuthEnabled")
    }
    
    func disableBiometricAuth() {
        UserDefaults.standard.set(false, forKey: "biometricAuthEnabled")
        logout()
    }
    
    func isBiometricAuthEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "biometricAuthEnabled")
    }
}
