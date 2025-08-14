//
//  ChantingView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct ChantingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var animationScale: CGFloat = 1.0
    @State private var nameClusterScale: CGFloat = 1.0
    @State private var showingGoalReached = false
    @State private var showingGoalMessage = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var goalReachedHaptic = UINotificationFeedbackGenerator()
    
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
                    
                    // Session control buttons (always available)
                    if dataManager.currentSession != nil {
                        HStack(spacing: 12) {
                            Button(action: {
                                dataManager.endSession()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "house.fill")
                                    Text("Home")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dataManager.endSession()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "stop.fill")
                                    Text("End Session")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // Tap area
                    tapAreaView
                        .frame(height: geometry.size.height * 0.2)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            hapticFeedback.prepare()
            goalReachedHaptic.prepare()
        }
        .overlay(
            // Non-intrusive goal reached message
            VStack {
                if showingGoalMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Goal Reached! 🎉")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 8)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.top, 50)
        )
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
        ScrollViewReader { proxy in
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
                                .id(index)
                        }
                    }
                    .padding()
                    .onChange(of: session.currentCount) { count in
                        // Auto-scroll to bottom when new names are added
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(count - 1, anchor: .bottom)
                        }
                    }
                }
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
        
        // Check if goal will be reached with this increment
        let wasGoalReached = dataManager.currentSession?.isGoalReached ?? false
        
        // Update data
        dataManager.incrementCount()
        
        // Check if goal is reached for the first time
        if let session = dataManager.currentSession,
           session.isGoalReached && !wasGoalReached {
            // Goal reached for first time - show celebration
            goalReachedHaptic.notificationOccurred(.success)
            
            withAnimation(.spring()) {
                showingGoalMessage = true
            }
            
            // Hide message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring()) {
                    showingGoalMessage = false
                }
            }
        }
    }
}

#Preview {
    ChantingView()
        .environmentObject(DataManager.shared)
        .onAppear {
            DataManager.shared.startSession(deityName: "Ram", targetCount: 108)
        }
}
