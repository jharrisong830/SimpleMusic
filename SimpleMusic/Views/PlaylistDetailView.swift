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
            if songs.isEmpty {
                ProgressView()
            }
            else {
                ForEach(songs) { song in
                    SongRow(song: song)
                }
            }
        }
        .navigationTitle(playlist.name)
        .task {
            switch playlist.sourcePlatform {
            case .spotify:
                do {
                    if SpotifyClient().checkRefresh() {
                        try await SpotifyClient().getRefreshToken()
                    }
                    songs = try await SpotifyClient().getPlaylistSongs(playlistID: playlist.spid)
                } catch {
                    print("error loading songs")
                }
            case .appleMusic:
                do {
                    songs = try await AppleMusicClient().getPlaylistSongs(playlistID: playlist.amid)
                } catch {
                    print("error loading songs")
                }
            }
        }
    }
}

//#Preview {
//    PlaylistDetailView()
//}
