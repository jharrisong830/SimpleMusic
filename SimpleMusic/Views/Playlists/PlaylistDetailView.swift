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
            switch playlist.platform {
            case .spotify:
                do {
                    if SpotifyClient.checkRefresh() {
                        try await SpotifyClient.getRefreshToken()
                    }
                    songs = try await SpotifyClient.getPlaylistSongs(playlistID: playlist.platformID)
                } catch {
                    print("error loading songs")
                }
            case .appleMusic:
                do {
                    songs = try await AppleMusicClient.getPlaylistSongs(playlistID: playlist.platformID)
                } catch {
                    print("error loading songs")
                }
            default:
                songs = []
//            case .youTube:
//                do {
//                    if YouTubeClient.checkRefresh() {
//                        try await YouTubeClient.getRefreshToken()
//                    }
//                    songs = try await YouTubeClient.getPlaylistItems(playlistID: playlist.ytid!)
//                } catch {
//                    print("error loading vids")
//                }
            }
        }
    }
}

//#Preview {
//    PlaylistDetailView()
//}
