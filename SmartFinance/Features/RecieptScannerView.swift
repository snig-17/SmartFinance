//
//  SwiftUIView.swift
//  SmartFinance
//
//  Created by Snigdha Tiwari  on 08/08/2025.
//

import SwiftUI
import Vision
import VisionKit
import PhotosUI

struct ReceiptScannerView: View {
    @StateObject private var receiptScanner = ReceiptScannerService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingDocumentScanner = false
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    
    // Callback to parent view
    let onReceiptScanned: (ScannedReceipt) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Scan Receipt")
                        .font(.title.bold())
                    
                    Text("Automatically extract transaction details from your receipt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Scanning Options
                VStack(spacing: 16) {
                    
                    // Document Scanner (Recommended)
                    Button(action: {
                        showingDocumentScanner = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Scan Receipt")
                                    .font(.headline)
                                Text("Best quality with automatic cropping")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                    
                    // Camera
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Take Photo")
                                    .font(.headline)
                                Text("Capture receipt with camera")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    
                    // Photo Library
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Choose from Photos")
                                    .font(.headline)
                                Text("Select existing receipt photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Processing Indicator
                if isProcessing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Scanning receipt...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Tips
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Tips for Best Results:")
                        .font(.subheadline.bold())
                    
                    Text("• Ensure good lighting")
                    Text("• Keep receipt flat and straight")
                    Text("• Include the entire receipt")
                    Text("• Avoid shadows and glare")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(.gray.opacity(0.05))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDocumentScanner) {
            DocumentScannerView { image in
                processScannedImage(image)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                processScannedImage(image)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            PhotoPicker { image in
                processScannedImage(image)
            }
        }
        .onChange(of: receiptScanner.scannedReceipt) { receipt in
            if let receipt = receipt {
                onReceiptScanned(receipt)
                dismiss()
            }
        }
    }
    
    private func processScannedImage(_ image: UIImage) {
        selectedImage = image
        isProcessing = true
        
        receiptScanner.scanReceipt(image: image) { success in
            DispatchQueue.main.async {
                isProcessing = false
                if !success {
                    // Show error message
                    print("❌ Receipt scanning failed")
                }
            }
        }
    }
}
