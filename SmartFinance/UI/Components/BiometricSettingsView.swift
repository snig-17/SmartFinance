//
//  BiometricSettingsView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import SwiftUI

struct BiometricSettingsView: View {
    @StateObject private var biometricManager = BiometricManager()
    @State private var isBiometricEnabled: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: biometricManager.getBiometricType().icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(biometricManager.getBiometricType().displayName) Authentication")
                                .font(.headline)
                            
                            Text(getStatusDescription())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isBiometricEnabled)
                            .disabled(biometricManager.getAuthenticationState() != .available)
                    }
                } header: {
                    Text("Security")
                } footer: {
                    Text(getFooterText())
                }
                
                Section("Session Settings") {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Auto-Lock Timeout")
                                .font(.headline)
                            Text("5 minutes of inactivity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Privacy") {
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text("Local Authentication")
                                .font(.headline)
                            Text("Your biometric data never leaves your device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if isBiometricEnabled {
                    Section {
                        Button("Test Authentication") {
                            testAuthentication()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Biometric Settings")
            .onAppear {
                isBiometricEnabled = biometricManager.isBiometricAuthEnabled()
            }
            .onChange(of: isBiometricEnabled) { enabled in
                handleBiometricToggle(enabled)
            }
            .alert("Authentication", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func getStatusDescription() -> String {
        switch biometricManager.getAuthenticationState() {
        case .available:
            return "Available and ready to use"
        case .notEnrolled:
            return "Not set up - Go to Settings to configure"
        case .lockedOut:
            return "Temporarily locked - Use passcode to unlock"
        case .notAvailable:
            return "Not available on this device"
        case .notDetermined:
            return "Status unknown"
        }
    }
    
    private func getFooterText() -> String {
        let biometricType = biometricManager.getBiometricType().displayName
        return "When enabled, you'll need to authenticate with \(biometricType) or your device passcode each time you open SmartFinance."
    }
    
    private func handleBiometricToggle(_ enabled: Bool) {
        if enabled {
            // Test authentication before enabling
            Task {
                let success = await biometricManager.authenticateWithBiometrics(
                    reason: "Authenticate to enable biometric security for SmartFinance"
                )
                
                await MainActor.run {
                    if success {
                        biometricManager.enableBiometricAuth()
                        alertMessage = "Biometric authentication enabled successfully!"
                        showingAlert = true
                    } else {
                        isBiometricEnabled = false
                        alertMessage = biometricManager.authenticationError ?? "Failed to enable biometric authentication"
                        showingAlert = true
                    }
                }
            }
        } else {
            biometricManager.disableBiometricAuth()
            alertMessage = "Biometric authentication disabled"
            showingAlert = true
        }
    }
    
    private func testAuthentication() {
        Task {
            let success = await biometricManager.authenticateWithBiometrics(
                reason: "Test biometric authentication"
            )
            
            await MainActor.run {
                alertMessage = success ? "Authentication successful!" : (biometricManager.authenticationError ?? "Authentication failed")
                showingAlert = true
            }
        }
    }
}

#Preview {
    BiometricSettingsView()
}
