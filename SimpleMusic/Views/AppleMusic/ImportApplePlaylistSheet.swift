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
            ImportPlaylistGeneralView(isPresented: $isPresented, newplaylists: $newplaylists, navPath: $navPath)
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
            .task {
                do {
                    newplaylists = try await AppleMusicClient.getPlaylists()
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
