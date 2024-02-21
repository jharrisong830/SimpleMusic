//
//  ImportPlaylistView.swift
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

struct ImportPlaylistView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var playlist: PlaylistData
    @Binding var navPath: [PlaylistData]
    @Binding var isPresented: Bool
    
    @State private var songs: [SongData] = []
    
    var body: some View {
        List {
            PlaylistDetailView(playlist: playlist, songs: $songs) 
            SongListView(songs: $songs)
        }
        .navigationTitle(playlist.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    withAnimation {
                        modelContext.insert(playlist)
                        for song in songs {
                            song.playlist = playlist
                            modelContext.insert(song)
                        }
                        _ = navPath.popLast()
                        isPresented = false
                    }
                } label: {
                    Text("Add to App")
                        .foregroundStyle(playlist.platform == .spotify ? Color("SpotifyGreen") : playlist.platform == .appleMusic ? .pink : .red)
                }
            }
        }
        .task {
            switch playlist.platform {
            case .spotify:
                do {
                    if SpotifyClient.checkRefresh() {
                        try await SpotifyClient.getRefreshToken()
                    }
                    songs = try await SpotifyClient.getPlaylistSongs(playlist: playlist)
                } catch {
                    print("error loading songs")
                }
            case .appleMusic:
                do {
                    songs = try await AppleMusicClient.getPlaylistSongs(playlist: playlist)
                } catch {
                    print("error loading songs")
                }
            default:
                songs = []
            }
        }
    }
}

//#Preview {
//    ImportPlaylistView()
//}
