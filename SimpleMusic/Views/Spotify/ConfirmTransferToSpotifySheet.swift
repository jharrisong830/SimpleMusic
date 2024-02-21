//
//  ConfirmTransferToSpotifySheet.swift
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

struct ConfirmTransferToSpotifySheet: View {
    @Bindable var playlist: PlaylistData
    @Binding var isPresented: Bool
    
    @State private var isMatchComplete = false
    @State private var matchedSongs: [SongData] = []
    @State private var presentIncompleteMatchAlert = false
    
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
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Text("Cancel")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            withAnimation {
                                if matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}) != 0 {
                                    presentIncompleteMatchAlert = true
                                }
                                else {
                                    Task {
                                        let newPlaylistID = try await SpotifyClient.createNewPlaylist(name: playlist.name, description: "")
                                        print(newPlaylistID)
                                        try await SpotifyClient.addSongsToPlaylist(spotifyPlaylistID: newPlaylistID, songs: matchedSongs)
                                    }
                                    isPresented = false
                                }
                            }
                        } label: {
                            Text("Add")
                                .foregroundStyle(Color("SpotifyGreen"))
                        }
                    }
                }
                .alert("Incomplete Match", isPresented: $presentIncompleteMatchAlert) {
                    Button(role: .cancel) {
                        withAnimation {}
                    } label: {
                        Text("No")
                    }
                    Button {
                        withAnimation {
                            Task {
                                matchedSongs.removeAll(where: {$0.matchState != .successful})
                                print(matchedSongs.count)
                                let newPlaylistID = try await SpotifyClient.createNewPlaylist(name: playlist.name, description: "")
                                print(newPlaylistID)
                                try await SpotifyClient.addSongsToPlaylist(spotifyPlaylistID: newPlaylistID, songs: matchedSongs)
                            }
                            isPresented = false
                        }
                    } label: {
                        Text("Yes")
                    }
                } message: {
                    Text("There are some songs that haven't been matched to a song on Spotify. You can still transfer this playlist, but the unmatched songs will be missing. Are you sure you want to continue?")
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
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        .task {
            do {
                matchedSongs = try await SpotifyClient.getSongMatches(playlist: playlist)
                isMatchComplete = true
            } catch {
                print("error")
            }
        }
    }
}

