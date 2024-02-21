//
//  SongMatchPicker.swift
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

struct SongMatchPicker: View {
    @Binding var song: SongData
    @Binding var searchResults: [SongData]
    @Binding var isPresented: Bool
    
    @State private var selection = SongData.emptySong
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults) { result in
                    Button {
                        withAnimation {
                            selection = result
                        }
                    } label: {
                        HStack {
                            SongRow(song: result)
                            Spacer()
                            if result == selection {
                                Image(systemName: "checkmark")
                                    .symbolRenderingMode(.multicolor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Matched Results")
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
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        withAnimation {
                            if selection != SongData.emptySong {
                                song.name = selection.name
                                song.artists = selection.artists
                                song.albumName = selection.albumName
                                song.albumArtists = selection.albumArtists
                                song.isrc = selection.isrc
                                song.platform = selection.platform
                                song.platformID = selection.platformID
                                song.platformURL = selection.platformURL
                                song.coverImage = selection.coverImage
                                song.matchState = .successful
                            }
                            isPresented = false
                        }
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

//#Preview {
//    SongMatchPicker()
//}
