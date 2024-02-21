//
//  ImportApplePlaylistSheet.swift
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
