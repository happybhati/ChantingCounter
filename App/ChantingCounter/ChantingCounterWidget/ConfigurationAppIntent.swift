//
//  ConfigurationAppIntent.swift
//  ChantingCounterWidget
//
//  Created by Happy Bhati on 8/14/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "ChantingCounter Widget"
    static var description = IntentDescription("Track your spiritual practice progress right on your home screen.")
    
    // For simplicity, we don't need configuration parameters for now
    // The widget will automatically show the user's chanting data
}
