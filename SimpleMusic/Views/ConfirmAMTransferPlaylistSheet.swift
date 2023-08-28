//
//  ConfirmAMTransferPlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 8/11/23.
//

import SwiftUI

struct ConfirmAMTransferPlaylistSheet: View {
    @Bindable var playlist: PlaylistData
    @Binding var spotifySongs: [SongData]
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
                            Text("\(matchedSongs.reduce(0, {$1.amid.isEmpty ? $0+1 : $0}))")
                                .foregroundStyle(.red)
                        }
                    } header: {
                        Text("Details")
                    }
                    if matchedSongs.reduce(0, {$1.amid.isEmpty ? $0+1 : $0}) != 0 {
                        Section {
                            ForEach($matchedSongs) { $song in
                                if song.amid.isEmpty {
                                    NavigationLink(destination: SongMatchView(song: $song)) {
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
                            if !song.amid.isEmpty {
                                NavigationLink(destination: SongMatchView(song: $song)) {
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
                                let newPlaylistID = try await AppleMusicClient().createNewPlaylist(name: playlist.name, description: "")
                                try await AppleMusicClient().addSongsToPlaylist(AMPlaylistID: newPlaylistID, songs: matchedSongs)
                            }
                            isPresented = false
                        } label: {
                            Text("Add")
                                .foregroundStyle(matchedSongs.reduce(0, {$1.amid.isEmpty ? $0+1 : $0}) != 0 ? .gray : .pink)
                        }
                        .disabled(matchedSongs.reduce(0, {$1.amid.isEmpty ? $0+1 : $0}) != 0)
                    }
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
