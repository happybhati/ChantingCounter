//
//  GoogleSignInManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import SwiftUI
// import GoogleSignIn // Will be added when GoogleSignIn SDK is integrated

@MainActor
class GoogleSignInManager: ObservableObject {
    static let shared = GoogleSignInManager()
    
    @Published var isSignedIn = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var userProfileImage: String?
    
    private init() {}
    
    // Configure Google Sign-In (call this in AppDelegate or App.swift)
    func configure() {
        // TODO: Add GoogleSignIn configuration
        // guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return }
        // GoogleSignIn.GIDSignIn.sharedInstance.configuration = GIDConfiguration(path: path)
        print("Google Sign-In configured (placeholder)")
    }
    
    // Sign in with Google
    func signIn() async {
        // TODO: Implement actual Google Sign-In
        // This is a placeholder implementation
        print("Google Sign-In initiated (placeholder)")
        
        // Simulate successful sign-in for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isSignedIn = true
            self.userEmail = "user@gmail.com"
            self.userName = "Google User"
            self.userProfileImage = nil
            
            // Update DataManager
            DataManager.shared.signInWithGoogle(
                email: self.userEmail ?? "",
                name: self.userName ?? ""
            )
        }
    }
    
    // Sign out
    func signOut() {
        // TODO: Implement actual Google Sign-Out
        // GoogleSignIn.GIDSignIn.sharedInstance.signOut()
        
        isSignedIn = false
        userEmail = nil
        userName = nil
        userProfileImage = nil
        
        print("Google Sign-Out completed (placeholder)")
    }
    
    // Check if user is already signed in
    func checkSignInStatus() {
        // TODO: Check actual Google Sign-In status
        // if let user = GoogleSignIn.GIDSignIn.sharedInstance.currentUser {
        //     isSignedIn = true
        //     userEmail = user.profile?.email
        //     userName = user.profile?.name
        // }
        print("Checking Google Sign-In status (placeholder)")
    }
}

// Extension to DataManager for Google Sign-In
extension DataManager {
    func signInWithGoogle(email: String, name: String) {
        userProfile.isGuest = false
        userProfile.appleUserID = nil // Clear Apple ID since using Google
        userProfile.name = name
        // Add email to user profile (we'll add this field next)
        saveData()
        
        Task {
            await syncWithCloudKit()
        }
    }
}
