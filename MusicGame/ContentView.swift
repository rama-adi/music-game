//
//  ContentView.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 06/05/24.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State var musicKitManager = MusicKitManager()
    var body: some View {
        NavigationStack {
            SelectPlaylistView().onAppear {
                Task {
                    await musicKitManager.authorize()
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
