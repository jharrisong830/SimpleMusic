//
//  SongDetailView.swift
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

struct SongDetailView: View {
    @Environment(\.openURL) private var openURL
    
    let song: SongData
    
    var body: some View {
        Section {
            SongRow(song: song)
            HStack {
                Text("Album")
                Spacer()
                Text(song.albumName)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("ISRC")
                Spacer()
                Text(song.isrc)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .textSelection(.enabled)
            }
            HStack {
                Text("Platform")
                Spacer()
                switch song.platform {
                case .appleMusic:
                    Text("Apple Music")
                        .foregroundStyle(.secondary)
                    Image("AM Logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 2)
                case .spotify:
                    Text("Spotify")
                        .foregroundStyle(.secondary)
                    Image("Spotify Logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 2)
                default:
                    Text("None")
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text("Platform ID")
                Spacer()
                Text(song.platformID)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .textSelection(.enabled)
            }
        } header: {
            Text("Details")
        }
            
        if song.platform == .spotify {
            Section {
                Button {
                    openURL(song.platformURL!)
                } label: {
                    Text("View on Spotify")
                        .foregroundStyle(song.platformURL == nil ? .gray : Color("SpotifyGreen"))
                }
                .disabled(song.platformURL == nil)
            }
        }
        else if song.platform == .appleMusic {
            Section {
                Button {
                    openURL(song.platformURL!)
                } label: {
                    Text("View on Apple Music")
                        .foregroundStyle(song.platformURL == nil ? .gray : .pink)
                }
                .disabled(song.platformURL == nil)
            }
        }
    }
}


