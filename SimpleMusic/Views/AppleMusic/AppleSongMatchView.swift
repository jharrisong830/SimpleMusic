//
//  SongDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/11/23.
//

import SwiftUI
import MusicKit

struct AppleSongMatchView: View {
    @Binding var song: SongData
    
    @State private var searchText = ""
    @State private var searchResults: [SongData] = []
    @State private var isPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        SongRow(song: song)
                        if song.matchState != .successful {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    HStack {
                        Text("ISRC")
                        Spacer()
                        Text(song.isrc)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    }
                    HStack {
                        Text("Apple Music ID")
                        Spacer()
                        Text(song.platformID)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    }
                }
                Section {
                    TextField("Search Apple Music", text: $searchText)
                        .onSubmit {
                            var catalogSearch = MusicCatalogSearchRequest(term: searchText, types: [Song.self])
                            catalogSearch.limit = 10
                            Task {
                                searchResults = []
                                let catalogResults = try await catalogSearch.response().songs
                                for amSong in catalogResults {
                                    searchResults.append(SongData(name: amSong.title, artists: [amSong.artistName], albumName: amSong.albumTitle ?? "", albumArtists: [amSong.artistName], isrc: amSong.isrc ?? "", platform: .appleMusic, platformID: amSong.id.rawValue, platformURL: nil, coverImage: amSong.artwork?.url(width: 300, height: 300)))
                                }
                                isPresented = true
                                searchText = ""
                            }
                        }
                        .submitLabel(.search)
                } header: {
                    Text("Rematch")
                }
            }
            .navigationTitle(song.name)
            .sheet(isPresented: $isPresented) {
                SongMatchPicker(song: $song, searchResults: $searchResults, isPresented: $isPresented)
            }
        }
    }
}

//#Preview {
//    SongDetailView()
//}
