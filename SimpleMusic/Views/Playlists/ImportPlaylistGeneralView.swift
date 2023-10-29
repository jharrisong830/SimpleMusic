//
//  ImportPlaylistGeneralView.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

import SwiftUI

struct ImportPlaylistGeneralView: View {
    @Binding var isPresented: Bool
    @Binding var newplaylists: [PlaylistData]
    @Binding var navPath: [PlaylistData]
    
    var body: some View {
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
        .navigationTitle("Import Playlist")
        
    }
}
