//
//  WatchConnectivityManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import WatchConnectivity
import SwiftUI

@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isWatchConnected = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendSessionUpdate(_ session: ChantingSession) {
        guard WCSession.default.isReachable else { return }
        
        let sessionData: [String: Any] = [
            "deityName": session.deityName,
            "currentCount": session.currentCount,
            "targetCount": session.targetCount ?? 0,
            "startTime": session.startTime.timeIntervalSince1970
        ]
        
        WCSession.default.sendMessage(
            ["sessionUpdate": sessionData],
            replyHandler: nil,
            errorHandler: { error in
                print("Failed to send session update: \(error)")
            }
        )
    }
    
    func sendCountIncrement(newCount: Int, lifetimeTotal: Int) {
        guard WCSession.default.isReachable else { return }
        
        WCSession.default.sendMessage(
            [
                "countUpdate": [
                    "currentCount": newCount,
                    "lifetimeTotal": lifetimeTotal
                ]
            ],
            replyHandler: nil,
            errorHandler: { error in
                print("Failed to send count update: \(error)")
            }
        )
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = activationState == .activated && session.isWatchAppInstalled
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchConnected = false
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from watch
        if let countUpdate = message["watchCountUpdate"] as? [String: Any],
           let newCount = countUpdate["currentCount"] as? Int {
            
            DispatchQueue.main.async {
                // Update iPhone app with watch count
                DataManager.shared.syncFromWatch(count: newCount)
            }
        }
    }
}

// Extension to DataManager for watch sync
extension DataManager {
    func syncFromWatch(count: Int) {
        guard var session = currentSession else { return }
        
        // Update session count from watch
        let difference = count - session.currentCount
        if difference > 0 {
            session.currentCount = count
            currentSession = session
            userProfile.totalLifetimeCount += difference
            saveData()
        }
    }
    
    func syncToWatch() {
        guard let session = currentSession else { return }
        WatchConnectivityManager.shared.sendSessionUpdate(session)
    }
}
