//
//  SettingsView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingSignOut = false
    @State private var reminderTime = Date()
    @State private var dailyGoal = ""
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        List {
            // Profile Section
            Section {
                HStack {
                    Image(systemName: dataManager.userProfile.isGuest ? "person.circle" : "person.crop.circle.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dataManager.userProfile.displayName)
                            .font(.headline)
                        
                        Text(dataManager.userProfile.isGuest ? "Guest User" : "Signed in with Apple")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if dataManager.userProfile.isGuest {
                        Button("Sign In") {
                            // Handle sign in
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Profile")
            }
            
            // Background Music Section
            Section {
                MusicControlView()
            } header: {
                Text("Background Music")
            }
            
            // Goals & Reminders Section
            Section {
                // Daily Goal
                HStack {
                    Image(systemName: "target")
                        .foregroundStyle(.blue)
                    
                    Text("Daily Goal")
                    
                    Spacer()
                    
                    TextField("Optional", text: $dailyGoal)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                
                // Reminder Toggle
                HStack {
                    Image(systemName: "bell")
                        .foregroundStyle(.orange)
                    
                    Toggle("Daily Reminder", isOn: $dataManager.userProfile.isReminderEnabled)
                }
                
                // Reminder Time
                if dataManager.userProfile.isReminderEnabled {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.purple)
                        
                        Text("Reminder Time")
                        
                        Spacer()
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
            } header: {
                Text("Goals & Reminders")
            }
            
            // Statistics Section
            Section {
                StatRow(title: "Lifetime Total", value: "\(dataManager.userProfile.totalLifetimeCount)", icon: "infinity")
                StatRow(title: "Current Streak", value: "\(dataManager.userProfile.currentStreak) days", icon: "flame.fill")
                StatRow(title: "Longest Streak", value: "\(dataManager.userProfile.longestStreak) days", icon: "trophy.fill")
                StatRow(title: "Member Since", value: formattedJoinDate, icon: "calendar")
            } header: {
                Text("Statistics")
            }
            
            // Data & Privacy Section
            Section {
                HStack {
                    Image(systemName: "icloud")
                        .foregroundStyle(.blue)
                    
                    Text("iCloud Sync")
                    
                    Spacer()
                    
                    Text(dataManager.userProfile.isGuest ? "Sign in required" : "Enabled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.green)
                        
                        Text("Export Data")
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {
                    clearAllData()
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                        
                        Text("Clear All Data")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Data & Privacy")
            }
            
            // Account Section
            if !dataManager.userProfile.isGuest {
                Section {
                    Button(action: {
                        showingSignOut = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.red)
                            
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Account")
                }
            }
            
            // App Info Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                Link(destination: URL(string: "https://github.com/happybhati/ChantingCounter")!) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(.blue)
                        
                        Text("GitHub Repository")
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadSettings()
            checkNotificationPermission()
        }
        .onChange(of: dataManager.userProfile.isReminderEnabled) { enabled in
            if enabled {
                requestNotificationPermission()
            } else {
                cancelNotifications()
            }
        }
        .onChange(of: reminderTime) { time in
            dataManager.userProfile.reminderTime = time
            if dataManager.userProfile.isReminderEnabled {
                scheduleNotification()
            }
            dataManager.saveData()
        }
        .onChange(of: dailyGoal) { goal in
            dataManager.userProfile.dailyGoal = Int(goal)
            dataManager.saveData()
        }
        .alert("Sign Out", isPresented: $showingSignOut) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                dataManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? Your data will be saved locally.")
        }
    }
    
    private var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dataManager.userProfile.joinDate)
    }
    
    private func loadSettings() {
        reminderTime = dataManager.userProfile.reminderTime ?? Date()
        dailyGoal = dataManager.userProfile.dailyGoal?.description ?? ""
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotification()
                } else {
                    dataManager.userProfile.isReminderEnabled = false
                    dataManager.saveData()
                }
            }
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Chant"
        content.body = "Take a moment for your spiritual practice today 🙏"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    private func exportData() {
        // Implementation for data export
        print("Exporting data...")
    }
    
    private func clearAllData() {
        dataManager.userProfile = UserProfile()
        dataManager.dailyStats = []
        dataManager.currentSession = nil
        dataManager.saveData()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.orange)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
    .environmentObject(DataManager.shared)
}
