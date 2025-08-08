//
//  BiometricAuthView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import SwiftUI

struct BiometricAuthView: View {
    @StateObject private var biometricManager = BiometricManager()
    @State private var showPasscodeOption = false
    @State private var isFirstLaunch = true
    
    let onAuthenticationSuccess: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "creditcard.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    Text("SmartFinance")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Your secure financial companion")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Authentication Section
                VStack(spacing: 30) {
                    
                    // Biometric Icon and Status
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            if biometricManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(2)
                            } else {
                                Image(systemName: biometricManager.getBiometricType().icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(getAuthenticationTitle())
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            
                            Text(getAuthenticationSubtitle())
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Authentication Buttons
                    VStack(spacing: 16) {
                        
                        // Primary Authentication Button
                        Button(action: {
                            Task {
                                await performPrimaryAuthentication()
                            }
                        }) {
                            HStack {
                                if !biometricManager.isLoading {
                                    Image(systemName: biometricManager.getBiometricType().icon)
                                        .font(.title2)
                                }
                                Text(getPrimaryButtonTitle())
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white)
                            .foregroundColor(.blue)
                            .cornerRadius(28)
                            .shadow(radius: 10)
                        }
                        .disabled(biometricManager.isLoading || biometricManager.getAuthenticationState() != .available)
                        
                        // Alternative Authentication Options
                        if showPasscodeOption || biometricManager.getAuthenticationState() != .available {
                            Button(action: {
                                Task {
                                    await authenticateWithPasscode()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .font(.title2)
                                    Text("Use Passcode")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .disabled(biometricManager.isLoading)
                        }
                        
                        // Show passcode option after failed biometric
                        if !showPasscodeOption && biometricManager.getAuthenticationState() == .available {
                            Button("Use Passcode Instead") {
                                showPasscodeOption = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    // Error Message
                    if let error = biometricManager.authenticationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.horizontal, 32)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Privacy Note
                Text("Your biometric data never leaves your device")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            setupInitialState()
        }
        .onChange(of: biometricManager.isAuthenticated) { authenticated in
            if authenticated {
                onAuthenticationSuccess()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func setupInitialState() {
        // Auto-trigger authentication on first launch if biometrics are available
        if isFirstLaunch && biometricManager.getAuthenticationState() == .available {
            isFirstLaunch = false
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                await performPrimaryAuthentication()
            }
        }
    }
    
    private func performPrimaryAuthentication() async {
        let authState = biometricManager.getAuthenticationState()
        
        switch authState {
        case .available:
            _ = await biometricManager.authenticateWithBiometrics()
        case .notEnrolled, .notAvailable:
            await authenticateWithPasscode()
        case .lockedOut:
            await authenticateWithPasscode()
        case .notDetermined:
            await authenticateWithPasscode()
        }
    }
    
    private func authenticateWithPasscode() async {
        _ = await biometricManager.authenticateWithPasscode()
    }
    
    private func getAuthenticationTitle() -> String {
        let authState = biometricManager.getAuthenticationState()
        let biometricType = biometricManager.getBiometricType()
        
        switch authState {
        case .available:
            return "Unlock with \(biometricType.displayName)"
        case .notEnrolled:
            return "Set up \(biometricType.displayName)"
        case .lockedOut:
            return "Biometrics Locked"
        case .notAvailable:
            return "Use Passcode"
        case .notDetermined:
            return "Authenticate"
        }
    }
    
    private func getAuthenticationSubtitle() -> String {
        let authState = biometricManager.getAuthenticationState()
        let biometricType = biometricManager.getBiometricType()
        
        switch authState {
        case .available:
            return "Touch the sensor or look at your device to continue"
        case .notEnrolled:
            return "Go to Settings to set up \(biometricType.displayName)"
        case .lockedOut:
            return "Use your passcode to unlock biometric authentication"
        case .notAvailable:
            return "Enter your device passcode to continue"
        case .notDetermined:
            return "Verify your identity to access your financial data"
        }
    }
    
    private func getPrimaryButtonTitle() -> String {
        if biometricManager.isLoading {
            return "Authenticating..."
        }
        
        let authState = biometricManager.getAuthenticationState()
        let biometricType = biometricManager.getBiometricType()
        
        switch authState {
        case .available:
            return "Unlock with \(biometricType.displayName)"
        case .notEnrolled:
            return "Go to Settings"
        case .lockedOut, .notAvailable, .notDetermined:
            return "Use Passcode"
        }
    }
}

// MARK: - Preview
#Preview {
    BiometricAuthView {
        print("Authentication successful!")
    }
}
