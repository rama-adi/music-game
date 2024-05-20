//
//  PlaylistImageView.swift
//  MusicGame
//
//  Created by Rama Adi Nugraha on 07/05/24.
//

import SwiftUI
import CachedAsyncImage

struct PlaylistImageView: View {
    var imageURL: String
    var title: String
    var curator: String
    
    var body: some View {
        VStack(spacing: 15) {
            GeometryReader { geometry in
                CachedAsyncImage(
                    url: imageURL,
                    placeholder: { progress in
                        ZStack {
                            Color.primary.opacity(0.1).cornerRadius(8)
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.width
                        )
                    },
                    image: { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                    }
                )
            }
            .aspectRatio(1, contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Text(curator)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
        }
    }
}

#Preview {
    struct Preview: View {
        private var gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        var body: some View {
            ScrollView {
                LazyVGrid(columns: gridItems) {
                    ForEach(1...10, id: \.self) {_ in
                        PlaylistImageView(
                            imageURL: "https://placehold.co/610x610.png",
                            title: "Yaruki Tracks",
                            curator: "Apple Music"
                        )
                    }
                }
            }
        }
    }
    
    return Preview()
}
