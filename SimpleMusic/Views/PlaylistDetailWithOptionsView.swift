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
    @State private var isTransferingToApple = false
    @State private var isTransferingToSpotify = false
    
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
                switch playlist.sourcePlatform {
                case.appleMusic:
                    Button {
                        Task {
                            isTransferingToSpotify = true
                        }
                    } label: {
                        Text("Transfer to Spotify")
                            .foregroundStyle(.green)
                    }
                case .spotify:
                    Button {
                        Task {
                            isTransferingToApple = true
                        }
                    } label: {
                        Text("Transfer to Apple Music")
                            .foregroundStyle(.pink)
                    }
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
