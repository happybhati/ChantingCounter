//
//  WelcomeView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var googleSignInManager = GoogleSignInManager.shared
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo and Branding
                VStack(spacing: 24) {
                    // Custom App Logo (use same design as app icon)
                    ZStack {
                        // Background circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, Color.orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        // Prayer hands icon
                        Image(systemName: "hands.clap.fill")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.white)
                    }
                    
                    // App Title and Tagline
                    VStack(spacing: 12) {
                        Text("ChantingCounter")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your spiritual practice companion")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Feature highlights
                        HStack(spacing: 20) {
                            FeatureBadge(icon: "🙏", text: "Multi-faith")
                            FeatureBadge(icon: "📊", text: "Progress")
                            FeatureBadge(icon: "⌚", text: "Apple Watch")
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                // Authentication Options
                VStack(spacing: 16) {
                    // Sign in with Apple
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            handleSignInWithApple(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    
                    // Sign in with Google
                    Button(action: {
                        Task {
                            await googleSignInManager.signIn()
                            if googleSignInManager.isSignedIn {
                                showingOnboarding = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Sign in with Google")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Continue as Guest
                    Button(action: {
                        continueAsGuest()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Continue as Guest")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Privacy & Trust Indicators
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        TrustBadge(icon: "lock.shield.fill", text: "Secure")
                        TrustBadge(icon: "icloud.fill", text: "Synced")
                        TrustBadge(icon: "heart.fill", text: "Ad-free")
                    }
                    
                    Text("Your spiritual journey data is private and secure")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
    }
    
    private func handleSignInWithApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userID = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let name = [fullName?.givenName, fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                dataManager.signInWithApple(
                    userID: userID,
                    name: name.isEmpty ? nil : name
                )
                
                showingOnboarding = true
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error)")
        }
    }
    
    private func continueAsGuest() {
        dataManager.userProfile.isGuest = true
        showingOnboarding = true
    }
}

// MARK: - Supporting Views

struct FeatureBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(width: 70)
    }
}

struct TrustBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.green)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(DataManager.shared)
}
