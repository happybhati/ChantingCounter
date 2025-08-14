//
//  MainTabView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TabView {
            // Home/Chanting Tab
            NavigationView {
                if dataManager.currentSession != nil {
                    ChantingView()
                } else {
                    HomeView()
                }
            }
            .tabItem {
                Image(systemName: "hands.sparkles.fill")
                Text("Chant")
            }
            
            // History Tab
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("History")
            }
            
            // Donation Tab
            NavigationView {
                DonationView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Donate")
            }
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .accentColor(.orange)
    }
}

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingNewSession = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome header
                VStack(spacing: 8) {
                    Text("Welcome, \(dataManager.userProfile.displayName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Ready to start your spiritual journey?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)
                
                // Stats cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Lifetime Total",
                        value: "\(dataManager.userProfile.totalLifetimeCount)",
                        icon: "infinity",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Current Streak",
                        value: "\(dataManager.userProfile.currentStreak) days",
                        icon: "flame.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "Longest Streak",
                        value: "\(dataManager.userProfile.longestStreak) days",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                    
                    StatCard(
                        title: "Today's Count",
                        value: "\(todaysCount)",
                        icon: "calendar",
                        color: .blue
                    )
                }
                .padding(.horizontal)
                
                // Start new session button
                Button(action: {
                    showingNewSession = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Start New Session")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal)
                
                // Recent sessions
                if !dataManager.dailyStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(dataManager.dailyStats.prefix(3)) { stats in
                            RecentActivityCard(stats: stats)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("ChantingCounter")
        .sheet(isPresented: $showingNewSession) {
            OnboardingView()
        }
    }
    
    private var todaysCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return dataManager.dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.totalCount ?? 0
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct RecentActivityCard: View {
    let stats: DailyStats
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stats.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(stats.totalCount) chants • \(stats.sessionsCompleted) sessions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(stats.totalCount)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager.shared)
}
