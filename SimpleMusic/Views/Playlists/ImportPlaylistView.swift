//
//  ImportPlaylistView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/10/23.
//

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
