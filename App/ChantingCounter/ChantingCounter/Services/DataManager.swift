//
//  DataManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit

/// Main data manager for the app using UserDefaults and CloudKit sync
@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var userProfile = UserProfile()
    @Published var currentSession: ChantingSession?
    @Published var dailyStats: [DailyStats] = []
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let cloudKitManager = CloudKitManager()
    
    // UserDefaults keys
    private enum Keys {
        static let userProfile = "userProfile"
        static let dailyStats = "dailyStats"
        static let currentSession = "currentSession"
    }
    
    private init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    
    func loadData() {
        // Load user profile
        if let data = userDefaults.data(forKey: Keys.userProfile),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
        
        // Load daily stats
        if let data = userDefaults.data(forKey: Keys.dailyStats),
           let stats = try? JSONDecoder().decode([DailyStats].self, from: data) {
            dailyStats = stats
        }
        
        // Load current session
        if let data = userDefaults.data(forKey: Keys.currentSession),
           let session = try? JSONDecoder().decode(ChantingSession.self, from: data) {
            currentSession = session
        }
        
        // Sync with CloudKit if signed in
        if !userProfile.isGuest {
            Task {
                await syncWithCloudKit()
            }
        }
    }
    
    func saveData() {
        // Save user profile
        if let data = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(data, forKey: Keys.userProfile)
        }
        
        // Save daily stats
        if let data = try? JSONEncoder().encode(dailyStats) {
            userDefaults.set(data, forKey: Keys.dailyStats)
        }
        
        // Save current session
        if let session = currentSession,
           let data = try? JSONEncoder().encode(session) {
            userDefaults.set(data, forKey: Keys.currentSession)
        } else {
            userDefaults.removeObject(forKey: Keys.currentSession)
        }
        
        // Update widget data
        updateWidgetData()
        
        // Sync with CloudKit if signed in
        if !userProfile.isGuest {
            Task {
                await syncWithCloudKit()
            }
        }
    }
    
    private func updateWidgetData() {
        // Save key data to shared UserDefaults for widget access
        let sharedDefaults = UserDefaults(suiteName: "group.com.hbhati.ChantingCounter")
        
        sharedDefaults?.set(userProfile.totalLifetimeCount, forKey: "totalLifetimeCount")
        sharedDefaults?.set(userProfile.currentStreak, forKey: "currentStreak")
        
        // Calculate today's count
        let today = Calendar.current.startOfDay(for: Date())
        let todayCount = dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.totalCount ?? 0
        sharedDefaults?.set(todayCount, forKey: "todayCount")
        
        // Force synchronization
        sharedDefaults?.synchronize()
        
        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Session Management
    
    func startSession(deityName: String, targetCount: Int? = nil) {
        let session = ChantingSession(
            deityName: deityName,
            targetCount: targetCount
        )
        currentSession = session
        saveData()
    }
    
    func incrementCount() {
        guard var session = currentSession else { return }
        session.currentCount += 1
        
        // Check if goal is reached
        if session.isGoalReached && !session.isCompleted {
            session.isCompleted = true
            session.endTime = Date()
        }
        
        currentSession = session
        
        // Update user's lifetime count
        userProfile.totalLifetimeCount += 1
        
        // Sync to watch
        WatchConnectivityManager.shared.sendCountIncrement(
            newCount: session.currentCount,
            lifetimeTotal: userProfile.totalLifetimeCount
        )
        
        saveData()
    }
    
    func endSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        
        // Update daily stats
        updateDailyStats(with: session)
        
        // Clear current session
        currentSession = nil
        saveData()
    }
    
    // MARK: - Statistics
    
    private func updateDailyStats(with session: ChantingSession) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Update existing daily stats
            dailyStats[index].totalCount += session.currentCount
            dailyStats[index].sessionsCompleted += 1
            dailyStats[index].timeSpent += session.duration
            dailyStats[index].deityBreakdown[session.deityName, default: 0] += session.currentCount
        } else {
            // Create new daily stats
            var newStats = DailyStats(date: today)
            newStats.totalCount = session.currentCount
            newStats.sessionsCompleted = 1
            newStats.timeSpent = session.duration
            newStats.deityBreakdown[session.deityName] = session.currentCount
            dailyStats.append(newStats)
        }
        
        // Update streak
        updateStreak()
    }
    
    private func updateStreak() {
        let sortedStats = dailyStats.sorted { $0.date > $1.date }
        var currentStreak = 0
        var longestStreak = 0
        var streakCount = 0
        
        let calendar = Calendar.current
        var expectedDate = calendar.startOfDay(for: Date())
        
        for stats in sortedStats {
            if calendar.isDate(stats.date, inSameDayAs: expectedDate) {
                if stats.totalCount > 0 {
                    streakCount += 1
                    if streakCount > longestStreak {
                        longestStreak = streakCount
                    }
                    if expectedDate == calendar.startOfDay(for: Date()) {
                        currentStreak = streakCount
                    }
                } else {
                    break
                }
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? expectedDate
            } else {
                break
            }
        }
        
        userProfile.currentStreak = currentStreak
        userProfile.longestStreak = max(longestStreak, userProfile.longestStreak)
    }
    
    // MARK: - CloudKit Sync
    
    func syncWithCloudKit() async {
        // Implementation for CloudKit sync
        // This would sync user data across devices
        await cloudKitManager.syncUserData(userProfile, dailyStats: dailyStats)
    }
    
    // MARK: - Authentication
    
    func signInWithApple(userID: String, name: String?) {
        userProfile.isGuest = false
        userProfile.appleUserID = userID
        userProfile.name = name
        saveData()
        
        Task {
            await syncWithCloudKit()
        }
    }
    
    func signOut() {
        // Preserve some data that shouldn't be lost on sign-out
        let lifetimeCount = userProfile.totalLifetimeCount
        let joinDate = userProfile.joinDate
        let currentStreak = userProfile.currentStreak
        let longestStreak = userProfile.longestStreak
        let totalDonations = userProfile.totalDonations
        let totalDonationAmount = userProfile.totalDonationAmount
        let preferredDeities = userProfile.preferredDeities
        let dailyGoal = userProfile.dailyGoal
        let favoriteSessionDuration = userProfile.favoriteSessionDuration
        let preferredMusicTrack = userProfile.preferredMusicTrack
        
        // Reset authentication-related data
        userProfile.isGuest = true
        userProfile.appleUserID = nil
        userProfile.googleEmail = nil
        userProfile.name = nil
        userProfile.email = nil
        userProfile.age = nil
        userProfile.gender = nil
        userProfile.profileImageURL = nil
        
        // Restore important data that should persist
        userProfile.totalLifetimeCount = lifetimeCount
        userProfile.joinDate = joinDate
        userProfile.currentStreak = currentStreak
        userProfile.longestStreak = longestStreak
        userProfile.totalDonations = totalDonations
        userProfile.totalDonationAmount = totalDonationAmount
        userProfile.preferredDeities = preferredDeities
        userProfile.dailyGoal = dailyGoal
        userProfile.favoriteSessionDuration = favoriteSessionDuration
        userProfile.preferredMusicTrack = preferredMusicTrack
        
        // Keep daily stats and current session as they represent spiritual practice
        // Only reset authentication, not spiritual progress
        
        saveData()
    }
    
    func recordDonation(productID: String) {
        // Record the donation in user profile
        userProfile.totalDonations += 1
        
        // You could also track total donation amount if needed
        // userProfile.totalDonationAmount += amount
        
        saveData()
    }
}

/// CloudKit manager for data synchronization
class CloudKitManager {
    func syncUserData(_ profile: UserProfile, dailyStats: [DailyStats]) async {
        // CloudKit implementation would go here
        // For now, this is a placeholder
        print("Syncing data to CloudKit...")
    }
}
