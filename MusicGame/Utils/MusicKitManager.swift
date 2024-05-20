//
//  MusicKitManager.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 06/05/24.
//

import Foundation
import Observation
import MusicKit
import MediaPlayer
import StoreKit
import Combine

@Observable class MusicKitManager {
    var authorized = false
    var musicPlayer: ApplicationMusicPlayer =  ApplicationMusicPlayer.shared
    
    var tracks: [Track] = []
    
    var currentDuration: TimeInterval = .zero
    
    @ObservationIgnored var displayLinkManager = DisplayLinkManager()
    
    func authorize() async -> Void {
        await SKCloudServiceController.requestAuthorization()
        let _ = await MusicAuthorization.request()
    }
    
    
    func getTracks() async -> Void {
        do {
            print("Getting tracks...")
            
            var playlistRequest = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: "pl.u-LdbqebdCx368k0x")
            playlistRequest.properties = [.tracks]
            let response  = try await playlistRequest.response()
            
            if let playlist = response.items.first {
                print("Playlist: \(playlist)")
                playlist.tracks?.forEach { track in
                    self.tracks.append(track)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func playTracks() async -> Void {
        do {
            musicPlayer.queue = ApplicationMusicPlayer.Queue(for: tracks)
            try await musicPlayer.prepareToPlay()
            try await musicPlayer.play()
            
            
            displayLinkManager.onUpdate = {
                DispatchQueue.main.async {
                    self.currentDuration = self.musicPlayer.playbackTime
                }
            }
        } catch {
            print("Error playing back: \(error)")
        }
    }
}
