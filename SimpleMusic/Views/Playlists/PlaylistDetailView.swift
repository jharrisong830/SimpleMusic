//
//  PlaylistDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 11/24/23.
//

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
                case .spotify:
                    Text("Spotify ID")
                    Spacer()
                    Text(playlist.platformID)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
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
                        .foregroundStyle(playlist.platformURL == nil ? .gray : .green)
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

