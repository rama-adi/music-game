//
//  SelectPlaylistView.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 07/05/24.
//

import SwiftUI
import MusadoraKit

extension SelectPlaylistView {
    struct PlaylistCollection: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let playlists: [Playlist]
    }
}

struct SelectPlaylistView: View {
    @State private var playlistCollections: [PlaylistCollection] = []
    @State private var isLoading = true
    @State private var searchQuery = ""
    
    private let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            if isLoading {
                loadingView
            } else {
                playlistsView
            }
        }
        .onAppear {
            Task {
                await getPlaylists()
            }
        }
        .navigationTitle("Let's play!")
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var playlistsView: some View {
        ScrollView {
            ForEach(playlistCollections) { collection in
                VStack(alignment: .leading) {
                    Text(collection.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(collection.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(collection.playlists) { playlist in
                        NavigationLink(destination: PickedPlaylistView(playlist: playlist)) {
                            PlaylistImageView(
                                imageURL: playlist.artwork?.url(
                                    width: 1080,
                                    height: 1080
                                )?.absoluteString ?? "",
                                title: playlist.name,
                                curator: playlist.curatorName ?? "Unknown"
                            )
                            .padding(.vertical, 10)
                        }
                    }
                }
            }
        }.padding()
    }
    
    private func getPlaylists() async {
        do {
            let (chartPlaylists) = try await (
                MCatalog.charts()
            )
            
            let chartFlattened = chartPlaylists.playlistCharts.flatMap { $0.items }
            
            let playlistCollections = [
                PlaylistCollection(
                    title: "Global charts",
                    subtitle: "Test your music knowledge with global charts!",
                    playlists: Array(chartFlattened)
                )
            ]
            
            self.playlistCollections = playlistCollections
            isLoading = false
        } catch {
            print("Error fetching playlists: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    SelectPlaylistView()
}
