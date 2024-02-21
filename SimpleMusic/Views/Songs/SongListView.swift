//
//  SongListView.swift
//  SimpleMusic
//
//  Created by John Graham on 11/25/23.
//

import SwiftUI

struct SongListView: View {
    @Binding var songs: [SongData]
    
    var body: some View {
        Section {
            if songs.isEmpty {
                ProgressView()
            }
            else {
                ForEach(songs.sorted(by: { $0.index < $1.index })) { song in
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


