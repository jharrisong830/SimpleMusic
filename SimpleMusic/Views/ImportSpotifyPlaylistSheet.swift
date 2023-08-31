//
//  ImportSpotifyPlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import SwiftUI
import KeychainAccess
import SwiftData

struct ImportSpotifyPlaylistSheet: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool
    
    @State private var newplaylists: [PlaylistData] = []
    @State private var refreshNeeded = SpotifyClient().checkRefresh()
    @State private var navPath: [PlaylistData] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
            if refreshNeeded {
                Spacer()
                Text("You need to sign in again. Go to Settings > Connect Spotify Account.")
                    .font(.title2)
                Spacer()
                Button(action: {
                    isPresented = false
                }, label: {
                    Text("Done")
                })
                .buttonStyle(ProminentButtonStyle())
                Button {
                    Task {
                        try await SpotifyClient().getRefreshToken()
                        refreshNeeded = false
                    }
                } label: {
                    Text("Try Refresh")
                }
                .buttonStyle(ProminentButtonStyle(color: .green))
                Spacer()
            }
            else {
                VStack {
                    List {
                        ForEach(newplaylists) { playlist in
                            NavigationLink(value: playlist) {
                                PlaylistRow(playlist: playlist)
                            }
                        }
                    }
                    .navigationDestination(for: PlaylistData.self) { playlist in
                        ImportPlaylistView(playlist: playlist, navPath: $navPath, isPresented: $isPresented)
                    }
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Text("Done")
                    })
                    .buttonStyle(ProminentButtonStyle(color: .green))
                    Spacer()
                }
                .navigationTitle("Import Playlist")
                .task {
                    do {
                        newplaylists = try await SpotifyClient().getPrivatePlaylists()
                    } catch {
                        isPresented = false
                    }
                }
            }
        }
    }
}

//#Preview {
//    ImportSpotifyPlaylistSheet(isPresented: .constant(true))
//}
