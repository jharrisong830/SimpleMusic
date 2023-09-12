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
                HStack {
                    Text("Name")
                    Spacer()
                    Text(playlist.name)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Platform")
                    Spacer()
                    switch playlist.sourcePlatform {
                    case .appleMusic:
                        Image("AM Logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    case .spotify:
                        Image("Spotify Logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                HStack {
                    switch playlist.sourcePlatform {
                    case .appleMusic:
                        Text("Apple Music ID")
                        Spacer()
                        Text(playlist.amid)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    case .spotify:
                        Text("Spotify ID")
                        Spacer()
                        Text(playlist.spid)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    }
                }
                HStack {
                    Text("Total Songs")
                    Spacer()
                    Text("\(songs.count)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Details")
            }
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
