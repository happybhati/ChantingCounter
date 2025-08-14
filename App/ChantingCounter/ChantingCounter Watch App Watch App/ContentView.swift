//
//  ContentView.swift
//  ChantingCounter Watch App Watch App
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var watchDataManager = WatchDataManager()
    @State private var animationScale: CGFloat = 1.0
    @State private var hapticFeedback = WKHapticType.click
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Deity name
                if let session = watchDataManager.currentSession {
                    Text(session.deityName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    // Progress indicator
                    if let target = session.targetCount {
                        ProgressView(value: session.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .scaleEffect(0.8)
                        
                        Text("\(session.currentCount)/\(target)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Counter display
                Text("\(watchDataManager.currentSession?.currentCount ?? 0)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .scaleEffect(animationScale)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: animationScale)
                
                Spacer()
                
                // Tap area - center of watch
                Button(action: {
                    incrementCounter()
                }) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.width * 0.7)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                
                                Text("TAP")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        )
                        .scaleEffect(animationScale)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Lifetime count
                Text("Total: \(watchDataManager.lifetimeCount)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .onAppear {
            watchDataManager.startSession()
        }
    }
    
    private func incrementCounter() {
        // Haptic feedback
        WKInterfaceDevice.current().play(hapticFeedback)
        
        // Animate
        animationScale = 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animationScale = 1.0
        }
        
        // Update counter
        watchDataManager.incrementCount()
    }
}

// Watch-specific data manager
@MainActor
class WatchDataManager: ObservableObject {
    @Published var currentSession: ChantingSession?
    @Published var lifetimeCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    
    func startSession() {
        // Load or create a default session
        if let data = userDefaults.data(forKey: "watchSession"),
           let session = try? JSONDecoder().decode(ChantingSession.self, from: data) {
            currentSession = session
        } else {
            // Default session
            currentSession = ChantingSession(deityName: "Om", targetCount: 108)
        }
        
        // Load lifetime count
        lifetimeCount = userDefaults.integer(forKey: "lifetimeCount")
    }
    
    func incrementCount() {
        guard var session = currentSession else { return }
        session.currentCount += 1
        currentSession = session
        
        lifetimeCount += 1
        
        // Save data
        if let data = try? JSONEncoder().encode(session) {
            userDefaults.set(data, forKey: "watchSession")
        }
        userDefaults.set(lifetimeCount, forKey: "lifetimeCount")
        
        // Sync with iPhone app (would use Watch Connectivity in real implementation)
        syncWithPhone()
    }
    
    private func syncWithPhone() {
        // Watch Connectivity implementation would go here
        print("Syncing with iPhone...")
    }
}

#Preview {
    ContentView()
}
