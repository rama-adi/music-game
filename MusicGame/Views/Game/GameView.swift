//
//  GameView.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 13/05/24.
//
import SwiftUI
import MusicKit
import AVFoundation

struct GameView: View {
    var tracks: [Track] = []
    @Binding var parentCloser: Bool
    
    @State private var correctTrack: Track?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var musicManager = MusicManager()
    
    @State private var searchText = ""
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = .zero
    @State private var currentSongIndex = 0
    @State private var guesses: [String] = Array(repeating: "", count: 6)
    
    @State private var allowedDuration: Int = 3
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State var songs: [String] = []
    
    @State private var alertTitle = ""
    @State private var showAlert = false
    
    var filteredSongs: [Track] {
        guard !searchText.isEmpty else { return [] }
        return tracks.filter {
            $0.title.lowercased().contains(searchText.lowercased())
            || $0.artistName.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            Text("Guess the song!")
                .font(.title)
                .bold()
                .padding()
            
            ScrollView {
                ForEach(0..<6) { index in
                    HStack {
                        Text(guesses[index])
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        Spacer()
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            ProgressView(value: currentTime, total: 10.0)
                .padding()
            
            HStack {
                Text("\(currentTime.formattedDuration)")
                Spacer()
                Button(action: {
                    playSong()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                
                Spacer()
                
                Button("+2s") {
                    buyDuration()
                }.buttonStyle(.bordered)
            }
            .padding()
            
            Divider()
            
            ZStack(alignment: .top) {
                TextField("Know it? Search for the title", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                
                if !filteredSongs.isEmpty && isTextFieldFocused {
                    List(filteredSongs, id: \.self) { track in
                        Text("\(track.artistName) - \(track.title)")
                            .lineLimit(1)
                            .onTapGesture {
                                checkAnswer(track: track)
                            }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 150)
                    .padding(.top, 50)
                    .transition(.move(edge: .top))
                    .zIndex(1)
                }
            }
            
            Spacer()
        }
        .onTick {
            guard let player = audioPlayer else {
                currentTime = .zero
                return
            }
            currentTime = player.currentTime
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                primaryButton: .default(Text("Retry")) {
                    // Reset game state for retry
                    resetGame()
                },
                secondaryButton: .cancel(Text("Close")) {
                    parentCloser = false
                }
            )
        }
        .onAppear {
            correctTrack = tracks.randomElement()
            songs = tracks.map {
                "\($0.title) - \($0.artistName)"
            }
        }
    }
    
    func playSong() {
        
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
            return
        }
        
        Task {
            do {
                let audio = try await musicManager.getAudioTrack(from: correctTrack!)
                audioPlayer = try AVAudioPlayer(data: audio)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                // Update UI to reflect that playback is happening
                DispatchQueue.main.async {
                    self.isPlaying = true
                }
                
                
                let timeToDispatch = DispatchTime.now() + DispatchTimeInterval.seconds(allowedDuration)
                
                
                DispatchQueue.main.asyncAfter(deadline: timeToDispatch) {
                    if let player = self.audioPlayer {
                        player.stop()
                        player.currentTime = 0 // Reset the current time
                        self.isPlaying = false
                    }
                    
                }
                
            } catch {
                print("Error playing audio:", error.localizedDescription)
            }
        }
    }
    
    
    
    func checkWinOrLose() {
        resetTextField()
        if currentSongIndex == guesses.count {
            if guesses.contains(where: { $0.starts(with: "✅") }) {
                alertTitle = "Game Over: You've used all your guesses!"
            } else {
                alertTitle = "Sorry, you didn't guess correctly in time."
            }
            showAlert = true
        }
    }
    
    func checkAnswer(track: Track) {
        resetTextField()
        if track.id != correctTrack?.id {
            guesses[currentSongIndex] = "❎ \(track.title) - \(track.artistName)"
        } else {
            guesses[currentSongIndex] = "✅ \(track.title) - \(track.artistName)"
            // Check if the game has been won in fewer than 6 turns
            if currentSongIndex < 5 {
                alertTitle = "Congratulations! You guessed correctly in \(currentSongIndex + 1) turns."
                showAlert = true
            }
        }
        currentSongIndex += 1
        checkWinOrLose()
    }
    
    func resetTextField() {
        searchText = ""
        isTextFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func buyDuration() {
        resetTextField()
        if currentSongIndex < guesses.count {
            guesses[currentSongIndex] = "❎ SKIPPED"
            allowedDuration += 2
            currentSongIndex += 1
            checkWinOrLose()
        }
    }
    
    
    func resetGame() {
        allowedDuration = 3
        correctTrack = tracks.randomElement()
        guesses = Array(repeating: "", count: 6)
        currentSongIndex = 0
        currentTime = .zero
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

#Preview {
    GameView(parentCloser: .constant(true))
}
