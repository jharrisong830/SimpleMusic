//
//  PlaylistSongListView.swift
//  SimpleMusic
//
//  Created by John Graham on 11/24/23.
//

import SwiftUI

struct PlaylistSongListView: View {
    @Bindable var playlist: PlaylistData
    @Binding var songs: [SongData]
    
    var body: some View {
        Section {
            if songs.isEmpty {
                ProgressView()
            }
            else {
                ForEach(songs) { song in
                    NavigationLink {
                        List {
                            SongDetailView(song: song)
                        }
                        .navigationTitle(song.name)
                    } label: {
                        SongRow(song: song)
                    }
                }
            }
        } header: {
            Text("Songs")
        }
    }
}


