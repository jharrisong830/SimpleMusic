//
//  SongMatchPicker.swift
//  SimpleMusic
//
//  Created by John Graham on 8/17/23.
//

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
                        selection = result
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
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        song.name = selection.name
                        song.artists = selection.artists
                        song.albumName = selection.albumName
                        song.albumArtists = selection.albumArtists
                        song.isrc = selection.isrc
                        song.amid = selection.amid
                        song.spid = selection.spid
                        song.coverImage = selection.coverImage
                        isPresented = false
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
