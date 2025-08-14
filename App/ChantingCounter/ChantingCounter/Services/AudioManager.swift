//
//  AudioManager.swift
//  ChantingCounter
//
//  Created by Happy Bhati on 8/14/25.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var currentTrack: MeditativeTrack?
    
    private var audioPlayer: AVAudioPlayer?
    private var audioSession = AVAudioSession.sharedInstance()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playTrack(_ track: MeditativeTrack) {
        guard let url = Bundle.main.url(forResource: track.filename, withExtension: "mp3") else {
            print("Could not find audio file: \(track.filename).mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.3 // Gentle background volume
            audioPlayer?.play()
            
            currentTrack = track
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentTrack = nil
        isPlaying = false
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
}

struct MeditativeTrack: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let filename: String
    let duration: String
    let description: String
    
    static let tracks = [
        MeditativeTrack(
            name: "Om Meditation",
            filename: "om_meditation",
            duration: "10:00",
            description: "Peaceful Om chanting with Tibetan bowls"
        ),
        MeditativeTrack(
            name: "Nature Sounds",
            filename: "nature_sounds",
            duration: "15:00",
            description: "Gentle rain and forest sounds"
        ),
        MeditativeTrack(
            name: "Flute Meditation",
            filename: "flute_meditation",
            duration: "12:00",
            description: "Soothing bamboo flute melodies"
        )
    ]
}

// Music control view for settings
struct MusicControlView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var volume: Float = 0.3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Background Music")
                .font(.headline)
            
            // Track selection
            if !MeditativeTrack.tracks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Track:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(MeditativeTrack.tracks) { track in
                        Button(action: {
                            if audioManager.currentTrack == track && audioManager.isPlaying {
                                audioManager.stopMusic()
                            } else {
                                audioManager.playTrack(track)
                            }
                        }) {
                            HStack {
                                Image(systemName: audioManager.currentTrack == track && audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Text(track.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(track.duration)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            } else {
                Text("Music files will be added in next update")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            
            // Volume control
            if audioManager.isPlaying {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Volume:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundStyle(.secondary)
                        
                        Slider(value: $volume, in: 0...1) { _ in
                            audioManager.setVolume(volume)
                        }
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .onAppear {
            volume = audioManager.audioPlayer?.volume ?? 0.3
        }
    }
}
