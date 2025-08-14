//
//  WelcomeView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange.gradient)
                    
                    VStack(spacing: 8) {
                        Text("ChantingCounter")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Track your spiritual journey")
                            .font(.title3)
                            .foregroundStyle(.secondary)
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
                
                // Privacy Note
                Text("Your data is securely stored and synced across your devices")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
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

#Preview {
    WelcomeView()
}
