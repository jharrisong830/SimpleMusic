//
//  SongRow.swift
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

struct SongRow: View {
    let song: SongData
    
    var body: some View {
        HStack {
            AsyncImage(url: song.coverImage) { image in
                image.resizable()
                    .frame(width: 37.5, height: 37.5)
                    .clipShape(RoundedRectangle(cornerRadius: song.platform != .spotify ? 2.5 : 0))
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
//    SongRow(song: SampleSongs.sampleSongs[0])
//        .modelContainer(songPreviewContainer)
//}
