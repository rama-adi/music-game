//
//  MiniplayerView.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 13/05/24.
//

import SwiftUI
import AVFoundation
import MusicKit
import CachedAsyncImage

struct MiniplayerView: View {
    @Binding var player: AVAudioPlayer?
    @Binding var currentTrack: Track?
    
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                // MARK: - Track image
                CachedAsyncImage(
                    url: currentTrack?
                        .artwork?
                        .url(width: 1080, height: 1080)?
                        .absoluteString ?? "https://placehold.co/1080x1080.png",
                    placeholder: { _ in
                        ZStack {
                            Color.primary.opacity(0.1)
                                .cornerRadius(4)
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 40, height: 40)
                        .matchedGeometryEffect(id: "image", in: namespace)
                    },
                    image: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(4)
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "image", in: namespace)
                    }
                )
                
                Text(currentTrack?.title ?? "Track title")
                    .font(.subheadline)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "title", in: namespace)
                
                Spacer()
                
                Button {
                    withAnimation {
                        player?.stop()
                        currentTrack = nil
                    }
                } label: {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.regularMaterial)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .transition(.move(edge: .bottom))
    }
}

#Preview {
    MiniplayerView(
        player: .constant(nil),
        currentTrack: .constant(nil)
    )
}
