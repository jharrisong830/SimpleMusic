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
    
    var body: some View {
        PlaylistDetailView(playlist: playlist)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        modelContext.insert(playlist)
                        _ = navPath.popLast()
                        isPresented = false
                    } label: {
                        Text("Add to App")
                            .foregroundStyle(playlist.sourcePlatform == .spotify ? .green : .pink)
                    }
                }
            }
    }
}

//#Preview {
//    ImportPlaylistView()
//}
