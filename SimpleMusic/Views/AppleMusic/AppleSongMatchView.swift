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
                SongDetailView(song: song)
                HStack {
                    Text("Match Status")
                    Spacer()
                    if song.matchState == .successful {
                        Label("Matched", systemImage: "checkmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                    else {
                        Label("Not Matched", systemImage: "xmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
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
                                    searchResults.append(SongData(name: amSong.title, artists: [amSong.artistName], albumName: amSong.albumTitle ?? "", albumArtists: [amSong.artistName], isrc: amSong.isrc ?? "", platform: .appleMusic, platformID: amSong.id.rawValue, platformURL: amSong.url, coverImage: amSong.artwork?.url(width: 300, height: 300), playlist: nil, index: song.index))
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
