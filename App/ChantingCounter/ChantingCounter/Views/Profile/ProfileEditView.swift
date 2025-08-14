//
//  ProfileEditView.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var selectedGender: Gender = .preferNotToSay
    @State private var favoriteSessionDuration: Double = 15
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange.gradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataManager.userProfile.displayName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Signed in with \(dataManager.userProfile.signInMethod)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if !dataManager.userProfile.isGuest {
                                Text("Member since \(formattedJoinDate)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Profile")
                }
                
                Section {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.blue)
                        
                        TextField("Full Name", text: $name)
                    }
                    
                    if !dataManager.userProfile.isGuest {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.green)
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.orange)
                        
                        Text("Age")
                        
                        Spacer()
                        
                        TextField("Optional", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(.purple)
                        
                        Text("Gender")
                        
                        Spacer()
                        
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(gender)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                } header: {
                    Text("Personal Information")
                } footer: {
                    Text("This information helps us provide a personalized experience and is kept private.")
                }
                
                Section {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.indigo)
                        
                        Text("Favorite Session Duration")
                        
                        Spacer()
                        
                        Text("\(Int(favoriteSessionDuration)) min")
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $favoriteSessionDuration, in: 5...60, step: 5) {
                        Text("Duration")
                    }
                    .accentColor(.orange)
                } header: {
                    Text("Preferences")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "infinity")
                                .foregroundStyle(.orange)
                            Text("Lifetime Chants")
                            Spacer()
                            Text("\(dataManager.userProfile.totalLifetimeCount)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.red)
                            Text("Current Streak")
                            Spacer()
                            Text("\(dataManager.userProfile.currentStreak) days")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            Text("Longest Streak")
                            Spacer()
                            Text("\(dataManager.userProfile.longestStreak) days")
                                .fontWeight(.semibold)
                        }
                    }
                } header: {
                    Text("Statistics")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private var formattedJoinDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dataManager.userProfile.joinDate)
    }
    
    private func loadCurrentProfile() {
        let profile = dataManager.userProfile
        name = profile.name ?? ""
        email = profile.email ?? profile.googleEmail ?? ""
        age = profile.age?.description ?? ""
        selectedGender = profile.gender ?? .preferNotToSay
        favoriteSessionDuration = Double(profile.favoriteSessionDuration)
    }
    
    private func saveProfile() {
        dataManager.userProfile.name = name.isEmpty ? nil : name
        dataManager.userProfile.email = email.isEmpty ? nil : email
        dataManager.userProfile.age = Int(age)
        dataManager.userProfile.gender = selectedGender
        dataManager.userProfile.favoriteSessionDuration = Int(favoriteSessionDuration)
        
        dataManager.saveData()
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(DataManager.shared)
}
