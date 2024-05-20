import SwiftUI
import MusicKit
import MusadoraKit
import CachedAsyncImage
import AVFoundation

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

struct PickedPlaylistView: View {
    var playlist: Playlist?
    
    @State private var isTitleVisible = true
    @State private var tracks: [Track] = []
    
    // MARK: - AUDIO PLAYBACK
    private let musicManager = MusicManager()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedTrack: Track?
    
    
    @State private var playGame = false
    
    
    private let HEIGHT = UIScreen.main.bounds.height
    
    var body: some View {
        List {
            // MARK: - Header Playlist Info
            Section {
                VStack(alignment: .center) {
                    playlistImage
                    Text(playlist?.name ?? "Unknown")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .global).minY)
                        })
                    Text(playlist?.curatorName ?? "No info")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section {
                Button("Play now") {
                    playGame.toggle()
                }
            }
            Section {
                if tracks.isEmpty {
                    ProgressView("Loading tracks...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(tracks) { track in
                        trackRow(track)
                    }
                }
            } header: {
                Text("Tracks")
            } footer: {
                Text("This is a free preview of the songs provided by Apple Music.")
            }
            
        }
        // MARK: - Game overlay
        .fullScreenCover(isPresented: $playGame) {
            GameView(tracks: tracks, parentCloser: $playGame)
        }
        // MARK: - Scroll spy
        .onPreferenceChange(ViewOffsetKey.self) { value in
            let nonNullOffset = value ?? 0
            withAnimation {
                isTitleVisible = nonNullOffset < HEIGHT
            }
        }
        .navigationTitle(isTitleVisible ? "" : playlist?.name ?? "Unknown")
        .onDisappear {
            audioPlayer?.stop()
        }
        .onAppear {
            fetchTracks()
        }
        // MARK: - Mini Player
        .overlay {
            if selectedTrack != nil {
                MiniplayerView(
                    player: $audioPlayer,
                    currentTrack: $selectedTrack
                )
            }
        }
    }
    
    // MARK: - Playlist Image
    @ViewBuilder var playlistImage: some View {
        CachedAsyncImage(
            url: playlist?.artwork?.url(width: 1080, height: 1080)?.absoluteString ?? "https://placehold.co/610x610.png",
            placeholder: { progress in
                ZStack {
                    Color.primary.opacity(0.1).cornerRadius(8)
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
                .frame(height: 200)
            },
            image: { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            }
        )
        .frame(height: HEIGHT / 4)
    }
    
    // MARK: - Track Row
    func trackRow(_ track: Track) -> some View {
        Button {
            playTrack(track)
        } label: {
            HStack {
                Image(systemName: "play")
                    .foregroundStyle(Color.accentColor)
                    .opacity(track == selectedTrack ? 1 : 0)
                
                VStack(alignment: .leading) {
                    Text(track.title)
                    Text(track.artistName)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text(track.duration?.formattedDuration ?? "00:00")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Fetch Tracks
    func fetchTracks() {
        Task {
            do {
                let playlist = try await MCatalog
                    .playlist(id: playlist?.id ?? "")
                    .with([.tracks])
                tracks = playlist
                    .tracks?
                    .reduce(into: [], { $0.append($1) })
                ?? []
                
            } catch {
                print("Error fetching tracks:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Play Track
    func playTrack(_ track: Track) {
        audioPlayer?.stop()
        
        Task {
            do {
                let audio = try await musicManager.getAudioTrack(from: track)
                audioPlayer = try AVAudioPlayer(data: audio)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                withAnimation(.spring()) {
                    selectedTrack = track
                }
            } catch {
                selectedTrack = nil
                print("Error playing audio:", error.localizedDescription)
            }
        }
    }
}

#Preview {
    PickedPlaylistView()
}
