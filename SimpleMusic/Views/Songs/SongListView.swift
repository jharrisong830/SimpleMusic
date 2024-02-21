//
//  SongListView.swift
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

struct SongListView: View {
    @Binding var songs: [SongData]
    
    var body: some View {
        Section {
            if songs.isEmpty {
                ProgressView()
            }
            else {
                ForEach(songs.sorted(by: { $0.index < $1.index })) { song in
                    NavigationLink {
                        List {
                            SongDetailView(song: song)
                        }
                        .navigationTitle(song.name)
                    } label: {
                        SongRow(song: song)
                    }
                }
            }
        } header: {
            Text("Songs")
        }
    }
}


