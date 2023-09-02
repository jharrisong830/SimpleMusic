//
//  ImportApplePlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 9/1/23.
//

import SwiftUI
import KeychainAccess
import SwiftData

struct ImportApplePlaylistSheet: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool
    
    @State private var newplaylists: [PlaylistData] = []
    @State private var navPath: [PlaylistData] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
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
                .buttonStyle(ProminentButtonStyle())
                Spacer()
            }
            .navigationTitle("Import Playlist")
            .task {
                do {
                    newplaylists = try await AppleMusicClient().getPlaylists()
                } catch {
                    isPresented = false
                }
            }
        }
    }
}

//#Preview {
//    ImportSpotifyPlaylistSheet(isPresented: .constant(true))
//}
