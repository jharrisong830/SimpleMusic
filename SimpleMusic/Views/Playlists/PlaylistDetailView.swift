//
//  PlaylistDetailView.swift
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

struct PlaylistDetailView: View {
    @Environment(\.openURL) private var openURL
    
    @Bindable var playlist: PlaylistData
    @Binding var songs: [SongData]
    
    var body: some View {
        Section {
            HStack {
                Text("Name")
                Spacer()
                Text(playlist.name)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Platform")
                Spacer()
                switch playlist.platform {
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
                switch playlist.platform {
                case .appleMusic:
                    Text("Apple Music ID")
                    Spacer()
                    Text(playlist.platformID)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                        .textSelection(.enabled)
                case .spotify:
                    Text("Spotify ID")
                    Spacer()
                    Text(playlist.platformID)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                        .textSelection(.enabled)
                default:
                    Image(systemName: "network")
                }
            }
            HStack {
                Text("Total Songs")
                Spacer()
                Text("\(songs.count)")
                    .foregroundStyle(.secondary)
            }
            if playlist.platform == .spotify {
                Button {
                    openURL(playlist.platformURL!)
                } label: {
                    Text("View on Spotify")
                        .foregroundStyle(playlist.platformURL == nil ? .gray : Color("SpotifyGreen"))
                }
                .disabled(playlist.platformURL == nil)
            }
            else if playlist.platform == .appleMusic {
                Button {
                    openURL(playlist.platformURL!)
                } label: {
                    Text("View on Apple Music")
                        .foregroundStyle(playlist.platformURL == nil ? .gray : .pink)
                }
                .disabled(playlist.platformURL == nil)
            }
        } header: {
            Text("Details")
        }
    }
}

