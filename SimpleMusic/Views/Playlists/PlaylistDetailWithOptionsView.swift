//
//  PlaylistDetailWithOptionsView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/10/23.
//

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistDetailWithOptionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    
    @Query private var userSettings: [UserSettings]
    
    @Bindable var playlist: PlaylistData
    @Binding var navPath: [PlaylistData]
    
    @State private var songs: [SongData] = []
    @State private var isTransferingToApple = false
    @State private var isTransferingToSpotify = false
    
    var body: some View {
        List {
            PlaylistDetailView(playlist: playlist, songs: $songs)
            
            PlaylistOptionsView(playlist: playlist, navPath: $navPath, isTransferingToSpotify: $isTransferingToSpotify, isTransferingToApple: $isTransferingToApple)
            
            PlaylistSongListView(playlist: playlist, songs: $songs)
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
        .sheet(isPresented: $isTransferingToApple) {
            ConfirmTransferToAppleSheet(playlist: playlist, isPresented: $isTransferingToApple)
        }
        .sheet(isPresented: $isTransferingToSpotify) {
            ConfirmTransferToSpotifySheet(playlist: playlist, isPresented: $isTransferingToSpotify)
        }
    }
    
}

//#Preview {
//    PlaylistDetailWithOptionsView()
//}
