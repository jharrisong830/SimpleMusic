//
//  PlaylistDetailWithOptionsView.swift
//  Copyright (C) 2024  John Graham
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistDetailWithOptionsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var userSettings: [UserSettings]
    
    @Bindable var playlist: PlaylistData
    @Binding var navPath: [PlaylistData]
    
//    @State private var songs: [SongData] = []
    @State private var isTransferingToApple = false
    @State private var isTransferingToSpotify = false
    
    var body: some View {
        List {
            PlaylistDetailView(playlist: playlist, songs: $playlist.songs)
            
            PlaylistOptionsView(playlist: playlist, navPath: $navPath, isTransferingToSpotify: $isTransferingToSpotify, isTransferingToApple: $isTransferingToApple)
            
            PlaylistSongListView(playlist: playlist)
        }
        .navigationTitle(playlist.name)
//        .task {
//            switch playlist.platform {
//            case .spotify:
//                do {
//                    if SpotifyClient.checkRefresh() {
//                        try await SpotifyClient.getRefreshToken()
//                    }
//                    songs = try await SpotifyClient.getPlaylistSongs(playlist: playlist)
//                } catch {
//                    print("error loading songs")
//                }
//            case .appleMusic:
//                do {
//                    songs = try await AppleMusicClient.getPlaylistSongs(playlist: playlist)
//                } catch {
//                    print("error loading songs")
//                }
//            default:
//                songs = []
////            case .youTube:
////                do {
////                    if YouTubeClient.checkRefresh() {
////                        try await YouTubeClient.getRefreshToken()
////                    }
////                    songs = try await YouTubeClient.getPlaylistItems(playlistID: playlist.ytid!)
////                } catch {
////                    print("error loading vids")
////                }
//            }
//        }
        .sheet(isPresented: $isTransferingToApple) {
            ConfirmTransferToAppleSheet(playlist: playlist, isPresented: $isTransferingToApple)
        }
        .sheet(isPresented: $isTransferingToSpotify) {
            ConfirmTransferToSpotifySheet(playlist: playlist, isPresented: $isTransferingToSpotify)
        }
    }
    
}

