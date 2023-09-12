//
//  SongRow.swift
//  SimpleMusic
//
//  Created by John Graham on 8/9/23.
//

import SwiftUI

struct SongRow: View {
    let song: SongData
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.coverImage!)) { image in
                image.resizable()
                    .frame(width: 37.5, height: 37.5)
                    .clipShape(RoundedRectangle(cornerRadius: 2.5))
            } placeholder: {
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: 37.5, height: 37.5)
                    .foregroundStyle(.gray.opacity(0.5))
                    .overlay(content: {Image(systemName: "questionmark.app.dashed").foregroundStyle(.blue)})
            }
            VStack(alignment: .leading) {
                Text(song.name)
                Text(song.artists.joined(separator: ", "))
                    .font(.footnote)
            }
        }
    }
}

//#Preview {
//    SongRow()
//}
