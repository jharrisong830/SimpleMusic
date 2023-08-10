//
//  PlaylistDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/7/23.
//

import SwiftUI

struct PlaylistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var playlist: PlaylistData
    @Binding var navPath: [PlaylistData]
    
    var body: some View {
        Text(playlist.name)
        Button(action: {
            modelContext.insert(playlist)
            _ = navPath.popLast()
        }, label: {
            Text("Add to app")
        })
        .buttonStyle(ProminentButtonStyle())
    }
}

//#Preview {
//    PlaylistDetailView()
//}
