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
    
    @State private var navPath: [SongData] = []
    @State private var isMatchComplete = false
    @State private var matchedSongs: [SongData] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
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
                    Section {
                        ForEach(matchedSongs) { song in
                            NavigationLink(value: song) {
                                HStack {
                                    SongRow(song: song)
                                    Spacer()
                                    if song.amid.isEmpty {
                                        Image(systemName: "xmark.circle.fill")
                                            .symbolRenderingMode(.multicolor)
                                    }
                                    else {
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
                .navigationDestination(for: SongData.self) { song in
                    SongDetailView(song: song)
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
                            isPresented = false
                        } label: {
                            Text("Add")
                                .foregroundStyle(.pink)
                        }
                    }
                }
            }
            else {
                VStack {
                    Text("Matching Spotify songs with Apple Music catalog.")
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
                matchedSongs = try await AppleMusicClient().createAppleMusicPlaylist(playlist: playlist)
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
