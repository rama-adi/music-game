//
//  MusicManager.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 13/05/24.
//

import Foundation
import MusicKit

struct MusicManager {
    func getAudioTrack(from track: Track) async throws -> Data {
        guard let url = track.previewAssets?.first?.url else {
            throw NSError(domain: "URL not found", code: 404, userInfo: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func getAudioTracks(from tracks: [Track]) async throws -> [Data] {
        var audioTracks: [Data] = []
        
        for track in tracks {
            do {
                let data = try await getAudioTrack(from: track)
                audioTracks.append(data)
            } catch {
                throw error
            }
        }
        
        return audioTracks
    }
}
