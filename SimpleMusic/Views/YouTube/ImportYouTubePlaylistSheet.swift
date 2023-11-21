//
//  ImportYouTubePlaylistSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 10/4/23.
//

import SwiftUI
import KeychainAccess
import SwiftData

//struct ImportYouTubePlaylistSheet: View {
//    @Environment(\.modelContext) private var modelContext
//    
//    @Binding var isPresented: Bool
//    
//    @State private var newplaylists: [PlaylistData] = []
//    @State private var navPath: [PlaylistData] = []
//    
//    var body: some View {
//        NavigationStack(path: $navPath) {
//            ImportPlaylistGeneralView(isPresented: $isPresented, newplaylists: $newplaylists, navPath: $navPath)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button {
//                        withAnimation {
//                            isPresented = false
//                        }
//                    } label: {
//                        Text("Cancel")
//                    }
//                }
//            }
//            .task {
//                do {
//                    if YouTubeClient.checkRefresh() {
//                        try await YouTubeClient.getRefreshToken()
//                    }
//                    newplaylists = try await YouTubeClient.getPlaylists()
//                } catch {
//                    isPresented = false
//                }
//            }
//        }
//    }
//}


