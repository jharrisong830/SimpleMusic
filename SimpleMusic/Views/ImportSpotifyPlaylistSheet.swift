//
//  ImportSpotifyPlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import SwiftUI
import SwiftData

struct ImportSpotifyPlaylistSheet: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool
    
    @State private var newplaylists: [PlaylistData] = []
    @State private var navPath: [PlaylistData] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
            ImportPlaylistGeneralView(isPresented: $isPresented, newplaylists: $newplaylists, navPath: $navPath)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .task {
                do {
                    if SpotifyClient().checkRefresh() {
                        try await SpotifyClient().getRefreshToken()
                    }
                    newplaylists = try await SpotifyClient().getPrivatePlaylists()
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
