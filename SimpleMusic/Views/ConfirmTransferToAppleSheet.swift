//
//  ConfirmAMTransferPlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 8/11/23.
//

import SwiftUI

struct ConfirmTransferToAppleSheet: View {
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
                                    NavigationLink(destination: AppleSongMatchView(song: $song)) {
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
                                NavigationLink(destination: AppleSongMatchView(song: $song)) {
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
                            if matchedSongs.reduce(0, {$1.matchState != .successful ? $0+1 : $0}) != 0 {
                                presentIncompleteMatchAlert = true
                            }
                            else {
                                Task {
                                    let newPlaylistID = try await AppleMusicClient().createNewPlaylist(name: playlist.name, description: "")
                                    print(newPlaylistID)
                                    try await AppleMusicClient().addSongsToPlaylist(AMPlaylistID: newPlaylistID, songs: matchedSongs)
                                }
                                isPresented = false
                            }
                        } label: {
                            Text("Add")
                                .foregroundStyle(.pink)
                        }
                    }
                }
                .alert("Incomplete Match", isPresented: $presentIncompleteMatchAlert) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("No")
                    }
                    Button {
                        Task {
                            matchedSongs.removeAll(where: {$0.matchState != .successful})
                            print(matchedSongs.count)
                            let newPlaylistID = try await AppleMusicClient().createNewPlaylist(name: playlist.name, description: "")
                            print(newPlaylistID)
                            try await AppleMusicClient().addSongsToPlaylist(AMPlaylistID: newPlaylistID, songs: matchedSongs)
                        }
                        isPresented = false
                    } label: {
                        Text("Yes")
                    }
                } message: {
                    Text("There are some songs that haven't been matched to a song on Apple Music. You can still transfer this playlist, but the unmatched songs will be missing. Are you sure you want to continue?")
                }
            }
            else {
                VStack {
                    Text("Matching Spotify songs with Apple Music catalog. Keep this screen open.")
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
                matchedSongs = try await AppleMusicClient().getSongMatches(playlist: playlist)
                isMatchComplete = true
            } catch {
                print("error")
            }
        }
    }
}

//#Preview {
//    ConfirmAMTransferPlaylistSheet()
//}
