//
//  OnboardingView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDeity: DeityName = .ram
    @State private var customDeityName = ""
    @State private var targetCount: String = ""
    @State private var hasTargetCount = false
    @State private var showingMainApp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("Let's Get Started")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose what you'd like to chant and set your goals")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Language Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Display Preferences")
                                .font(.headline)
                            
                            Toggle("Show deity names in original language", isOn: $dataManager.userProfile.useOriginalLanguageNames)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .onChange(of: dataManager.userProfile.useOriginalLanguageNames) { _ in
                                    dataManager.saveData()
                                }
                            
                            Text("Enable to see deity names in their traditional scripts (Hindi, Arabic, Gurmukhi)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Deity Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Choose Your Deity")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(DeityName.allCases.filter { $0 != .custom }, id: \.self) { deity in
                                    DeitySelectionCard(
                                        deity: deity,
                                        isSelected: selectedDeity == deity,
                                        useOriginalLanguage: dataManager.userProfile.useOriginalLanguageNames
                                    ) {
                                        selectedDeity = deity
                                        customDeityName = ""
                                    }
                                }
                            }
                            
                            // Custom deity option
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    selectedDeity = .custom
                                }) {
                                    HStack {
                                        Text("✨")
                                        Text("Custom")
                                        Spacer()
                                        if selectedDeity == .custom {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedDeity == .custom ? Color.orange.opacity(0.1) : Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedDeity == .custom ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                }
                                .foregroundColor(.primary)
                                
                                if selectedDeity == .custom {
                                    TextField("Enter deity name", text: $customDeityName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        // Goal Setting
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Set a Goal (Optional)")
                                .font(.headline)
                            
                            Toggle("I want to set a target count", isOn: $hasTargetCount)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                            
                            if hasTargetCount {
                                HStack {
                                    Text("Target Count:")
                                    TextField("e.g., 108", text: $targetCount)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Continue Button
                Button(action: {
                    startChanting()
                }) {
                    Text("Start Chanting")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canContinue ? Color.orange : Color.gray)
                        )
                }
                .disabled(!canContinue)
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        showingMainApp = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            MainTabView()
        }
    }
    
    private var canContinue: Bool {
        if selectedDeity == .custom {
            return !customDeityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    private var finalDeityName: String {
        if selectedDeity == .custom {
            return customDeityName.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return selectedDeity.name(useOriginalLanguage: dataManager.userProfile.useOriginalLanguageNames)
        }
    }
    
    private func startChanting() {
        let target = hasTargetCount ? Int(targetCount) : nil
        dataManager.startSession(deityName: finalDeityName, targetCount: target)
        showingMainApp = true
    }
}

struct DeitySelectionCard: View {
    let deity: DeityName
    let isSelected: Bool
    let useOriginalLanguage: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(deity.symbol)
                    .font(.system(size: 30))
                
                VStack(spacing: 2) {
                    Text(deity.name(useOriginalLanguage: useOriginalLanguage))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    if useOriginalLanguage && deity != .jesus && deity != .custom {
                        Text("(\(deity.displayName))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DataManager.shared)
}
