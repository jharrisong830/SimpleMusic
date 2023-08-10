//
//  PlaylistDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/7/23.
//

import SwiftUI

struct PlaylistDetailView: View {    
    @Bindable var playlist: PlaylistData
    
    @State private var songs: [SongData] = []
    
    var body: some View {
        List {
            ForEach(songs) { song in
                SongRow(song: song)
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
    }
}

//#Preview {
//    PlaylistDetailView()
//}
