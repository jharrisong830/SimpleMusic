//
//  PlaylistDetailWithOptionsView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/10/23.
//

import SwiftUI
import MusicKit

struct PlaylistDetailWithOptionsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var playlist: PlaylistData
    @Binding var navPath: [PlaylistData]
    
    @State private var songs: [SongData] = []
    @State private var isPresented = false
    
    var body: some View {
//        List {
//            Section {
//                ForEach(songs) { song in
//                    SongRow(song: song)
//                }
//            } header: {
//                Text("Songs")
//            }
//        }
        List {
            Section {
                Button {
                    Task {
                        isPresented = true
                    }
                } label: {
                    Text("Transfer to Apple Music")
                        .foregroundStyle(.pink)
                }
                Button {
                    modelContext.delete(playlist)
                    _ = navPath.popLast()
                } label: {
                    Text("Remove")
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Options")
            }
            Section {
                ForEach(songs) { song in
                    SongRow(song: song)
                }
            } header: {
                Text("Songs")
            }
        }
        .navigationTitle(playlist.name)
        .task {
            do {
                songs = try await SpotifyClient().getPlaylistSongs(playlistID: playlist.spid)
            } catch {
                print("error loading songs")
            }
        }
        .sheet(isPresented: $isPresented) {
            ConfirmAMTransferPlaylistSheet(playlist: playlist, spotifySongs: $songs, isPresented: $isPresented)
        }
    }
    
}

//#Preview {
//    PlaylistDetailWithOptionsView()
//}
