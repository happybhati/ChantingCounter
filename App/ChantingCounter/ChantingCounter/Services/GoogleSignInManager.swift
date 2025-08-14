//
//  GoogleSignInManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import SwiftUI
// TODO: Add GoogleSignIn import after adding the SDK via Swift Package Manager
// import GoogleSignIn

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
        // TODO: Uncomment when GoogleSignIn SDK is added via Swift Package Manager
        /*
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("GoogleService-Info.plist not found")
            return
        }
        
        guard let plistData = FileManager.default.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
              let clientId = plist["CLIENT_ID"] as? String else {
            print("Failed to parse GoogleService-Info.plist")
            return
        }
        
        guard let config = GIDConfiguration(clientID: clientId) else {
            print("Failed to create GID configuration")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = config
        */
        print("Google Sign-In configured (placeholder - add GoogleSignIn SDK)")
    }
    
    // Sign in with Google
    func signIn() async {
        // TODO: Uncomment when GoogleSignIn SDK is added
        /*
        do {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("No root view controller found")
                return
            }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user
            
            await MainActor.run {
                self.isSignedIn = true
                self.userEmail = user.profile?.email
                self.userName = user.profile?.name
                self.userProfileImage = user.profile?.imageURL(withDimension: 200)?.absoluteString
                
                // Update DataManager
                DataManager.shared.signInWithGoogle(
                    email: self.userEmail ?? "",
                    name: self.userName ?? ""
                )
            }
            
            print("Google Sign-In successful for user: \(user.profile?.email ?? "Unknown")")
            
        } catch {
            print("Google Sign-In failed: \(error.localizedDescription)")
        }
        */
        
        // Placeholder implementation - remove when real implementation is active
        print("Google Sign-In initiated (placeholder)")
        
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
        // TODO: Uncomment when GoogleSignIn SDK is added
        // GIDSignIn.sharedInstance.signOut()
        
        isSignedIn = false
        userEmail = nil
        userName = nil
        userProfileImage = nil
        
        // Update DataManager
        DataManager.shared.signOut()
        
        print("Google Sign-Out completed")
    }
    
    // Check if user is already signed in
    func checkSignInStatus() {
        // TODO: Uncomment when GoogleSignIn SDK is added
        /*
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] result, error in
                DispatchQueue.main.async {
                    if let user = result {
                        self?.isSignedIn = true
                        self?.userEmail = user.profile?.email
                        self?.userName = user.profile?.name
                        self?.userProfileImage = user.profile?.imageURL(withDimension: 200)?.absoluteString
                        
                        // Update DataManager if needed
                        if let email = user.profile?.email, let name = user.profile?.name {
                            DataManager.shared.signInWithGoogle(email: email, name: name)
                        }
                        
                        print("Google Sign-In restored for user: \(user.profile?.email ?? "Unknown")")
                    } else {
                        print("Failed to restore Google Sign-In: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
        */
        print("Checking Google Sign-In status (placeholder)")
    }
}

// Extension to DataManager for Google Sign-In
extension DataManager {
    func signInWithGoogle(email: String, name: String) {
        userProfile.isGuest = false
        userProfile.appleUserID = nil // Clear Apple ID since using Google
        userProfile.googleEmail = email
        userProfile.name = name
        saveData()
        
        Task {
            await syncWithCloudKit()
        }
    }
    
    func signOut() {
        userProfile.isGuest = true
        userProfile.appleUserID = nil
        userProfile.googleEmail = nil
        userProfile.name = nil
        saveData()
    }
}
