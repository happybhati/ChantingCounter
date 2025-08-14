//
//  HistoryView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI
// import Charts // Commented out for now - will add Charts framework later

struct HistoryView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Chart - Placeholder for now
                if !filteredStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Progress")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Simple bar chart placeholder
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(filteredStats.prefix(7)) { stats in
                                VStack {
                                    Rectangle()
                                        .fill(.orange.gradient)
                                        .frame(width: 30, height: CGFloat(stats.totalCount) * 2 + 10)
                                    
                                    Text("\(Calendar.current.component(.day, from: stats.date))")
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                }
                
                // Statistics summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        StatisticCard(
                            title: "Total Chants",
                            value: "\(totalChants)",
                            icon: "number",
                            color: .blue
                        )
                        
                        StatisticCard(
                            title: "Average Daily",
                            value: "\(averageDaily)",
                            icon: "chart.bar.fill",
                            color: .green
                        )
                        
                        StatisticCard(
                            title: "Best Day",
                            value: "\(bestDay)",
                            icon: "star.fill",
                            color: .yellow
                        )
                        
                        StatisticCard(
                            title: "Active Days",
                            value: "\(activeDays)",
                            icon: "calendar.badge.checkmark",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Detailed history
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(filteredStats.sorted { $0.date > $1.date }) { stats in
                        DailyHistoryCard(stats: stats)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("History")
    }
    
    private var filteredStats: [DailyStats] {
        let calendar = Calendar.current
        let now = Date()
        
        let cutoffDate: Date
        switch selectedTimeRange {
        case .week:
            cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            cutoffDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            cutoffDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return dataManager.dailyStats.filter { $0.date >= cutoffDate }
    }
    
    private var totalChants: Int {
        filteredStats.reduce(0) { $0 + $1.totalCount }
    }
    
    private var averageDaily: Int {
        guard !filteredStats.isEmpty else { return 0 }
        return totalChants / filteredStats.count
    }
    
    private var bestDay: Int {
        filteredStats.map { $0.totalCount }.max() ?? 0
    }
    
    private var activeDays: Int {
        filteredStats.filter { $0.totalCount > 0 }.count
    }
}

struct StatisticCard: View {
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
                .font(.title3)
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

struct DailyHistoryCard: View {
    let stats: DailyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stats.formattedDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(stats.sessionsCompleted) sessions • \(formattedDuration)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(stats.totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
            
            if !stats.deityBreakdown.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Breakdown:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(stats.deityBreakdown.keys.sorted()), id: \.self) { deity in
                        HStack {
                            Text(deity)
                                .font(.caption)
                            Spacer()
                            Text("\(stats.deityBreakdown[deity] ?? 0)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    private var formattedDuration: String {
        let minutes = Int(stats.timeSpent / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
