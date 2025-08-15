//
//  ChantingCounterWidget.swift
//  ChantingCounterWidget
//
//  Created by Happy Bhati on 8/14/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalCount: 1008, currentStreak: 7, todayCount: 27, motivationalQuote: "Every chant brings you closer to inner peace 🙏")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), totalCount: 1008, currentStreak: 7, todayCount: 27, motivationalQuote: "Every chant brings you closer to inner peace 🙏")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = loadChantingData()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60))) // Update every 15 minutes
        return timeline
    }
    
    private func loadChantingData() -> SimpleEntry {
        // Load data from shared UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.hbhati.ChantingCounter")
        
        let totalCount = sharedDefaults?.integer(forKey: "totalLifetimeCount") ?? 0
        let currentStreak = sharedDefaults?.integer(forKey: "currentStreak") ?? 0
        let todayCount = sharedDefaults?.integer(forKey: "todayCount") ?? 0
        
        let quotes = [
            "Every chant brings you closer to inner peace 🙏",
            "Your spiritual journey is a path of love and light ✨",
            "Consistency in practice leads to transformation 🌟",
            "Each count is a step towards divine connection 🕉️",
            "Your dedication to practice inspires others ❤️",
            "Today is a beautiful day for spiritual growth 🌸",
            "Keep counting, keep growing, keep believing 💫",
            "Your spiritual practice is a gift to yourself 🎁",
            "Every moment of devotion matters 🌺",
            "You are on a sacred journey of the soul 🦋"
        ]
        
        let randomQuote = quotes.randomElement() ?? quotes[0]
        
        return SimpleEntry(
            date: Date(),
            totalCount: totalCount,
            currentStreak: currentStreak,
            todayCount: todayCount,
            motivationalQuote: randomQuote
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalCount: Int
    let currentStreak: Int
    let todayCount: Int
    let motivationalQuote: String
}

struct ChantingCounterWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (2x2)
struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                // App icon
                Image(systemName: "hands.clap.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                // Total count
                Text("\(entry.totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Total Chants")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
                
                // Streak
                if entry.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("\(entry.currentStreak)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget (4x2)
struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Left side - Stats
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "hands.clap.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("ChantingCounter")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        StatRow(title: "Total", value: "\(entry.totalCount)", icon: "infinity")
                        StatRow(title: "Today", value: "\(entry.todayCount)", icon: "calendar")
                        StatRow(title: "Streak", value: "\(entry.currentStreak) days", icon: "flame.fill")
                    }
                }
                
                Spacer()
                
                // Right side - Motivation
                VStack {
                    Text("🙏")
                        .font(.title)
                    
                    Text("Keep Going!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Large Widget (4x4)
struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "hands.clap.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("ChantingCounter")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(entry.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Main stats
                HStack(spacing: 20) {
                    StatCard(title: "Total Chants", value: "\(entry.totalCount)", icon: "infinity", color: .white)
                    StatCard(title: "Today", value: "\(entry.todayCount)", icon: "calendar", color: .white)
                    StatCard(title: "Streak", value: "\(entry.currentStreak) days", icon: "flame.fill", color: .yellow)
                }
                
                Divider()
                    .background(.white.opacity(0.3))
                
                // Motivational quote
                VStack(spacing: 8) {
                    Text("💫 Daily Inspiration")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(entry.motivationalQuote)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Call to action
                Text("Tap to continue your spiritual journey")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .italic()
            }
            .padding(16)
        }
    }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 12)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct ChantingCounterWidget: Widget {
    let kind: String = "ChantingCounterWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ChantingCounterWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ChantingCounter")
        .description("Track your spiritual practice progress right on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    ChantingCounterWidget()
} timeline: {
    SimpleEntry(date: .now, totalCount: 1008, currentStreak: 7, todayCount: 27, motivationalQuote: "Every chant brings you closer to inner peace 🙏")
    SimpleEntry(date: .now, totalCount: 1050, currentStreak: 8, todayCount: 42, motivationalQuote: "Your dedication to practice inspires others ❤️")
}

#Preview(as: .systemMedium) {
    ChantingCounterWidget()
} timeline: {
    SimpleEntry(date: .now, totalCount: 1008, currentStreak: 7, todayCount: 27, motivationalQuote: "Every chant brings you closer to inner peace 🙏")
    SimpleEntry(date: .now, totalCount: 1050, currentStreak: 8, todayCount: 42, motivationalQuote: "Your dedication to practice inspires others ❤️")
}

#Preview(as: .systemLarge) {
    ChantingCounterWidget()
} timeline: {
    SimpleEntry(date: .now, totalCount: 1008, currentStreak: 7, todayCount: 27, motivationalQuote: "Every chant brings you closer to inner peace 🙏")
    SimpleEntry(date: .now, totalCount: 1050, currentStreak: 8, todayCount: 42, motivationalQuote: "Your dedication to practice inspires others ❤️")
}
