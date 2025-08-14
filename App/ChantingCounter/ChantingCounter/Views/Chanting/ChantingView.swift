//
//  ChantingView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct ChantingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var animationScale: CGFloat = 1.0
    @State private var nameClusterScale: CGFloat = 1.0
    @State private var showingGoalReached = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.orange.opacity(0.1), .pink.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with deity name and goal
                    headerView
                        .padding(.top)
                    
                    // Animated name cluster
                    nameClusterView
                        .frame(maxHeight: geometry.size.height * 0.4)
                    
                    // Counter display
                    counterView
                        .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Tap area
                    tapAreaView
                        .frame(height: geometry.size.height * 0.25)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            hapticFeedback.prepare()
        }
        .alert("Goal Reached! 🎉", isPresented: $showingGoalReached) {
            Button("Continue") { }
            Button("End Session") {
                dataManager.endSession()
            }
        } message: {
            Text("Congratulations! You've reached your chanting goal.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            if let session = dataManager.currentSession {
                Text(session.deityName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if let target = session.targetCount {
                    HStack {
                        Text("Goal: \(target)")
                        Spacer()
                        Text("\(Int(session.progress * 100))% Complete")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    
                    // Progress bar
                    ProgressView(value: session.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private var nameClusterView: some View {
        ScrollView {
            if let session = dataManager.currentSession {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: adaptiveColumnCount),
                    spacing: 8
                ) {
                    ForEach(0..<session.currentCount, id: \.self) { index in
                        Text(session.deityName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.2))
                            )
                            .scaleEffect(nameClusterScale)
                            .animation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                                .delay(Double(index % 10) * 0.02),
                                value: nameClusterScale
                            )
                    }
                }
                .padding()
            }
        }
    }
    
    private var counterView: some View {
        VStack(spacing: 16) {
            if let session = dataManager.currentSession {
                Text("\(session.currentCount)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .scaleEffect(animationScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animationScale)
                
                Text("Total Count")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            // Lifetime count
            VStack(spacing: 4) {
                Text("Lifetime Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(dataManager.userProfile.totalLifetimeCount)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
    }
    
    private var tapAreaView: some View {
        Button(action: {
            incrementCounter()
        }) {
            VStack(spacing: 12) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                
                Text("Tap to Count")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .scaleEffect(animationScale)
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
    }
    
    private var adaptiveColumnCount: Int {
        guard let session = dataManager.currentSession else { return 3 }
        let count = session.currentCount
        
        if count < 50 { return 3 }
        else if count < 200 { return 4 }
        else if count < 500 { return 5 }
        else { return 6 }
    }
    
    private func incrementCounter() {
        // Haptic feedback
        hapticFeedback.impactOccurred()
        
        // Animate counter
        animationScale = 1.2
        nameClusterScale = 1.1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animationScale = 1.0
            nameClusterScale = 1.0
        }
        
        // Update data
        dataManager.incrementCount()
        
        // Check if goal is reached
        if let session = dataManager.currentSession,
           session.isGoalReached && !showingGoalReached {
            showingGoalReached = true
        }
    }
}

#Preview {
    ChantingView()
        .onAppear {
            DataManager.shared.startSession(deityName: "Ram", targetCount: 108)
        }
}
