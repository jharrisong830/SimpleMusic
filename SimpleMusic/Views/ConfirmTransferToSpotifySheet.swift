//
//  ConfirmTransferToSpotifySheet.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

import SwiftUI

struct ConfirmTransferToSpotifySheet: View {
    @Bindable var playlist: PlaylistData
    @Binding var isPresented: Bool
    
    @State private var isMatchComplete = false
    @State private var matchedSongs: [SongData] = []
    
    var body: some View {
        NavigationStack {
            if isMatchComplete {
                List {
                    Section {
                        HStack {
                            Text("Total Songs")
                            Spacer()
                            Text("\(matchedSongs.count)")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("To Be Checked")
                            Spacer()
                            Text("\(matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}))")
                                .foregroundStyle(.red)
                        }
                    } header: {
                        Text("Details")
                    }
                    if matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}) != 0 {
                        Section {
                            ForEach($matchedSongs) { $song in
                                if song.matchState != .successful {
                                    NavigationLink(destination: SpotifySongMatchView(song: $song)) {
                                        HStack {
                                            SongRow(song: song)
                                            Spacer()
                                            Image(systemName: "xmark.circle.fill")
                                                .symbolRenderingMode(.multicolor)
                                        }
                                    }
                                }
                            }
                        } header: {
                            Text("Needs Review")
                        }
                    }
                    Section {
                        ForEach($matchedSongs) { $song in
                            if song.matchState == .successful {
                                NavigationLink(destination: SpotifySongMatchView(song: $song)) {
                                    HStack {
                                        SongRow(song: song)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .symbolRenderingMode(.multicolor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Matches")
                    }
                }
                .navigationTitle("Matched Results")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            Task {
                                // TODO: let newPlaylistID = try await AppleMusicClient().createNewPlaylist(name: playlist.name, description: "")
                                // TODO: print(newPlaylistID)
                                // TODO: try await AppleMusicClient().addSongsToPlaylist(AMPlaylistID: newPlaylistID, songs: matchedSongs)
                                let newPlaylistID = try await SpotifyClient().createNewPlaylist(name: playlist.name, description: "")
                                print(newPlaylistID)
                                try await SpotifyClient().addSongsToPlaylist(spotifyPlaylistID: newPlaylistID, songs: matchedSongs)
                            }
                            isPresented = false
                        } label: {
                            Text("Add")
                                .foregroundStyle(matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}) != 0 ? .gray : .green)
                        }
                        .disabled(matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}) != 0)
                    }
                }
            }
            else {
                VStack {
                    Text("Matching Apple Music songs with Spotify catalog. Keep this screen open.")
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    ProgressView()
                }
                .navigationTitle("Matched Results")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        .task {
            do {
                matchedSongs = try await SpotifyClient().getSongMatches(playlist: playlist)
                isMatchComplete = true
            } catch {
                print("error")
            }
        }
    }
}

