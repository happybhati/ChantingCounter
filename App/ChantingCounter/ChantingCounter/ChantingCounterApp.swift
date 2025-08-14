//
//  ChantingCounterApp.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

@main
struct ChantingCounterApp: App {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if dataManager.userProfile.isGuest && dataManager.userProfile.appleUserID == nil {
                    WelcomeView()
                } else {
                    MainTabView()
                }
            }
            .environmentObject(dataManager)
        }
    }
}
