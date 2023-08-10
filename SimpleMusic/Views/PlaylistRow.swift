//
//  PlaylistRow.swift
//  SimpleMusic
//
//  Created by John Graham on 8/6/23.
//

import SwiftUI

struct PlaylistRow: View {
    @Bindable var playlist: PlaylistData
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: playlist.coverImage!)) { image in
                image.resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } placeholder: {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.gray)
                    .overlay(content: {Image(systemName: "questionmark").foregroundStyle(.green)})
            }
            Text(playlist.name)
        }
    }
}

//#Preview {
//    PlaylistRow()
//}
