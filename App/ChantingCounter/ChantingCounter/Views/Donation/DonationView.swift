//
//  DonationView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI
import StoreKit

struct DonationView: View {
    @StateObject private var storeKit = StoreKitManager.shared
    @State private var showingThankYou = false
    @State private var purchaseError: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.pink.gradient)
                    
                    Text("Support Our Mission")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Help us maintain and improve ChantingCounter")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Mission statement
                VStack(alignment: .leading, spacing: 16) {
                    Text("Our Promise")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DonationBulletPoint(
                            icon: "hand.raised.fill",
                            text: "Donations are completely optional - only give if you can comfortably afford it"
                        )
                        
                        DonationBulletPoint(
                            icon: "wrench.and.screwdriver.fill",
                            text: "Your support helps us maintain the app, add new features, and keep it ad-free"
                        )
                        
                        DonationBulletPoint(
                            icon: "globe.asia.australia.fill",
                            text: "Any surplus donations will go toward humanitarian causes and helping those in need"
                        )
                        
                        DonationBulletPoint(
                            icon: "lock.fill",
                            text: "All donations are processed securely through Apple's payment system"
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // Donation options
                VStack(spacing: 16) {
                    Text("Choose Your Support Level")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DonationButton(
                            title: "Small Coffee",
                            subtitle: "Thank you for your kindness",
                            amount: storeKit.getFormattedPrice(for: .smallCoffee),
                            color: .blue,
                            isLoading: storeKit.isLoading
                        ) {
                            Task {
                                await processDonation(.smallCoffee)
                            }
                        }
                        
                        DonationButton(
                            title: "Large Coffee",
                            subtitle: "Your generosity is appreciated",
                            amount: storeKit.getFormattedPrice(for: .largeCoffee),
                            color: .orange,
                            isLoading: storeKit.isLoading
                        ) {
                            Task {
                                await processDonation(.largeCoffee)
                            }
                        }
                        
                        DonationButton(
                            title: "Generous Support",
                            subtitle: "Helping us grow and serve better",
                            amount: storeKit.getFormattedPrice(for: .generousSupport),
                            color: .green,
                            isLoading: storeKit.isLoading
                        ) {
                            Task {
                                await processDonation(.generousSupport)
                            }
                        }
                        
                        DonationButton(
                            title: "Spiritual Patron",
                            subtitle: "Supporting our mission deeply",
                            amount: storeKit.getFormattedPrice(for: .spiritualPatron),
                            color: .purple,
                            isLoading: storeKit.isLoading
                        ) {
                            Task {
                                await processDonation(.spiritualPatron)
                            }
                        }
                    }
                }
                
                // Gratitude message
                VStack(spacing: 12) {
                    Text("🙏")
                        .font(.system(size: 40))
                    
                    Text("Whether you donate or not, we're grateful you're part of our spiritual community. Your practice and positive energy are the greatest gifts.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding()
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle("Donate")
        .alert("Thank You! 🙏", isPresented: $showingThankYou) {
            Button("Continue") { }
        } message: {
            Text("Your generous support helps us maintain the app and contribute to humanitarian causes. May your kindness return to you multiplied.")
        }
        .alert("Purchase Error", isPresented: .constant(purchaseError != nil)) {
            Button("OK") { purchaseError = nil }
        } message: {
            if let error = purchaseError {
                Text(error)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .donationCompleted)) { _ in
            showingThankYou = true
        }
    }
    
    private func processDonation(_ productID: StoreKitManager.ProductID) async {
        do {
            try await storeKit.purchase(productID)
        } catch {
            purchaseError = error.localizedDescription
        }
    }
}

struct DonationBulletPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DonationButton: View {
    let title: String
    let subtitle: String
    let amount: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: isLoading ? {} : action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(amount)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

#Preview {
    NavigationView {
        DonationView()
    }
}
