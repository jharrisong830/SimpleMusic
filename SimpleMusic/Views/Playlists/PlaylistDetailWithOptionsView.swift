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
    
    @Query private var userSettings: [UserSettings]
    
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
                    switch playlist.platform {
                    case .appleMusic:
                        Image("AM Logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    case .spotify:
                        Image("Spotify Logo")
                            .resizable()
                            .frame(width: 20, height: 20)
                    default:
                        Image(systemName: "network")
                    }
                }
                HStack {
                    switch playlist.platform {
                    case .appleMusic:
                        Text("Apple Music ID")
                        Spacer()
                        Text(playlist.platformID)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    case .spotify:
                        Text("Spotify ID")
                        Spacer()
                        Text(playlist.platformID)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    default:
                        Image(systemName: "network")
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
                switch playlist.platform {
                case.appleMusic:
                    if userSettings[0].spotifyActive {
                        Button {
                            Task {
                                isTransferingToSpotify = true
                            }
                        } label: {
                            Text("Transfer to Spotify")
                                .foregroundStyle(.green)
                        }
                    }
                case .spotify:
                    if MusicAuthorization.currentStatus == .authorized {
                        Button {
                            Task {
                                isTransferingToApple = true
                            }
                        } label: {
                            Text("Transfer to Apple Music")
                                .foregroundStyle(.pink)
                        }
                    }
                default:
                    Image(systemName: "network")
                }
                Button {
                    withAnimation {
                        modelContext.delete(playlist)
                        _ = navPath.popLast()
                    }
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
