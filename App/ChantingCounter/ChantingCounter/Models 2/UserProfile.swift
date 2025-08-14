//
//  UserProfile.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import SwiftUI

/// User profile and preferences
struct UserProfile: Codable {
    var id = UUID()
    var name: String?
    var isGuest: Bool = true
    var appleUserID: String?
    var preferredDeities: [String] = []
    var dailyGoal: Int?
    var reminderTime: Date?
    var isReminderEnabled: Bool = false
    var totalLifetimeCount: Int = 0
    var joinDate: Date = Date()
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    
    /// Check if user is signed in with Apple
    var isSignedIn: Bool {
        return !isGuest && appleUserID != nil
    }
    
    /// Display name for UI
    var displayName: String {
        return name ?? (isGuest ? "Guest" : "User")
    }
}

/// Daily chanting statistics
struct DailyStats: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var totalCount: Int = 0
    var sessionsCompleted: Int = 0
    var timeSpent: TimeInterval = 0
    var deityBreakdown: [String: Int] = [:]
    
    /// Check if daily goal was met
    func goalMet(dailyGoal: Int?) -> Bool {
        guard let goal = dailyGoal else { return false }
        return totalCount >= goal
    }
    
    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
