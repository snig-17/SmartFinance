//
//  AuthenticationGate.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import SwiftUI

struct AuthenticationGate<Content: View>: View {
    @StateObject private var biometricManager = BiometricManager()
    @State private var isAuthenticated = false
    @State private var showAuthView = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isAuthenticated {
                content
                    .onAppear {
                        // Start session monitoring
                        startSessionMonitoring()
                    }
            } else {
                BiometricAuthView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isAuthenticated = true
                    }
                }
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkAuthenticationOnForeground()
        }
    }
    
    private func checkAuthenticationStatus() {
        if biometricManager.shouldRequireAuthentication() {
            isAuthenticated = false
        } else {
            // User doesn't have biometric auth enabled or recently authenticated
            isAuthenticated = !biometricManager.isBiometricAuthEnabled()
        }
    }
    
    private func checkAuthenticationOnForeground() {
        if biometricManager.isBiometricAuthEnabled() && biometricManager.shouldRequireAuthentication() {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAuthenticated = false
            }
        }
    }
    
    private func startSessionMonitoring() {
        // Monitor for session timeout
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            if biometricManager.shouldRequireAuthentication() {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isAuthenticated = false
                }
            }
        }
    }
}
