//
//  StoreKitManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: NSObject, ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var isLoading = false
    @Published var error: Error?
    
    // Product identifiers - these need to match what you configure in App Store Connect
    enum ProductID: String, CaseIterable {
        case smallCoffee = "com.chantingcounter.donation.small"
        case largeCoffee = "com.chantingcounter.donation.large" 
        case generousSupport = "com.chantingcounter.donation.generous"
        case spiritualPatron = "com.chantingcounter.donation.patron"
        
        var displayName: String {
            switch self {
            case .smallCoffee: return "Small Coffee"
            case .largeCoffee: return "Large Coffee"
            case .generousSupport: return "Generous Support"
            case .spiritualPatron: return "Spiritual Patron"
            }
        }
        
        var price: String {
            switch self {
            case .smallCoffee: return "$2.99"
            case .largeCoffee: return "$4.99"
            case .generousSupport: return "$9.99"
            case .spiritualPatron: return "$19.99"
            }
        }
    }
    
    private var products: [Product] = []
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private override init() {
        super.init()
        
        // Start a transaction listener as close to the app launch as possible
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func requestProducts() async {
        do {
            isLoading = true
            
            // Request products from App Store
            products = try await Product.products(for: ProductID.allCases.map { $0.rawValue })
            
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            self.error = error
            isLoading = false
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ productID: ProductID) async throws {
        guard let product = products.first(where: { $0.id == productID.rawValue }) else {
            throw StoreKitError.productNotFound
        }
        
        isLoading = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the purchase
                let transaction = try Self.checkVerified(verification)
                
                // Process the successful purchase
                await handleSuccessfulPurchase(transaction)
                
                // Finish the transaction
                await transaction.finish()
                
            case .userCancelled:
                // User cancelled the purchase
                print("User cancelled the purchase")
                
            case .pending:
                // Purchase is pending (e.g., parental approval)
                print("Purchase is pending approval")
                
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Handling
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in StoreKit.Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try await Self.checkVerified(result)
                    await self.handleSuccessfulPurchase(transaction)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the transaction is verified. If it isn't,
        // this function rethrows the verification error.
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    private func handleSuccessfulPurchase(_ transaction: StoreKit.Transaction) async {
        // Handle the successful purchase
        print("Successfully purchased: \(transaction.productID)")
        
        // Update UI or save purchase record
        // For donations, you might want to show a thank you message
        // and potentially track total donations in user profile
        
        // Update user profile with donation
        DataManager.shared.recordDonation(productID: transaction.productID)
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: .donationCompleted,
            object: transaction.productID
        )
    }
    
    // MARK: - Restore Purchases (if needed)
    
    func restorePurchases() async {
        do {
            // For non-consumable and auto-renewable subscriptions
            try await AppStore.sync()
        } catch {
            print("Failed to restore purchases: \(error)")
            self.error = error
        }
    }
    
    // MARK: - Product Information
    
    func getProduct(for id: ProductID) -> Product? {
        return products.first(where: { $0.id == id.rawValue })
    }
    
    func getFormattedPrice(for id: ProductID) -> String {
        if let product = getProduct(for: id) {
            return product.displayPrice
        }
        return id.price // Fallback to hardcoded price
    }
}

// MARK: - Custom Errors

enum StoreKitError: LocalizedError {
    case failedVerification
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let donationCompleted = Notification.Name("donationCompleted")
}


