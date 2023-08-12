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
        VStack {
            PlaylistDetailView(playlist: playlist)
            Button {
                modelContext.insert(playlist)
                _ = navPath.popLast()
                isPresented = false
            } label: {
                Text("Add to App")
            }
            .buttonStyle(ProminentButtonStyle(color: .green))
        }
    }
}

//#Preview {
//    ImportPlaylistView()
//}
