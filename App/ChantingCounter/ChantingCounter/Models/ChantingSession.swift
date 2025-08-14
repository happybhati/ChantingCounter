//
//  ChantingSession.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import SwiftUI

/// Represents a chanting session with goal and progress tracking
struct ChantingSession: Identifiable, Codable {
    let id = UUID()
    var deityName: String
    var targetCount: Int?
    var currentCount: Int = 0
    var startTime: Date = Date()
    var endTime: Date?
    var isCompleted: Bool = false
    
    /// Calculate session duration
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard let target = targetCount, target > 0 else { return 0.0 }
        return min(Double(currentCount) / Double(target), 1.0)
    }
    
    /// Check if session goal is reached
    var isGoalReached: Bool {
        guard let target = targetCount else { return false }
        return currentCount >= target
    }
}

/// Predefined deity names for quick selection
enum DeityName: String, CaseIterable {
    case ram = "Ram"
    case radha = "Radha"
    case krishna = "Krishna"
    case om = "Om"
    case jesus = "Jesus"
    case allah = "Allah"
    case waheguru = "Waheguru"
    case custom = "Custom"
    
    var displayName: String {
        return rawValue
    }
    
    /// Original language name for the deity
    var originalLanguageName: String {
        switch self {
        case .ram: return "राम" // Hindi/Sanskrit
        case .radha: return "राधा" // Hindi/Sanskrit  
        case .krishna: return "कृष्ण" // Hindi/Sanskrit
        case .om: return "ॐ" // Sanskrit
        case .jesus: return "Jesus" // English (original)
        case .allah: return "الله" // Arabic
        case .waheguru: return "ਵਾਹਿਗੁਰੂ" // Gurmukhi/Punjabi
        case .custom: return "Custom" // User-defined
        }
    }
    
    /// Language/tradition the deity belongs to
    var tradition: String {
        switch self {
        case .ram, .radha, .krishna, .om: return "Hindu/Sanskrit"
        case .jesus: return "Christian" 
        case .allah: return "Islamic"
        case .waheguru: return "Sikh"
        case .custom: return "Custom"
        }
    }
    
    /// Get display name based on user preference for original language
    func name(useOriginalLanguage: Bool) -> String {
        return useOriginalLanguage ? originalLanguageName : displayName
    }
    
    var symbol: String {
        switch self {
        case .ram: return "🙏"
        case .radha: return "🌸"
        case .krishna: return "🦚"
        case .om: return "🕉️"
        case .jesus: return "✝️"
        case .allah: return "☪️"
        case .waheguru: return "☬"
        case .custom: return "✨"
        }
    }
}
