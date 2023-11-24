//
//  SongDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 10/29/23.
//

import SwiftUI

struct SongDetailView: View {
    @Environment(\.openURL) private var openURL
    
    let song: SongData
    
    var body: some View {
        Section {
            SongRow(song: song)
            HStack {
                Text("ISRC")
                Spacer()
                Text(song.isrc)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
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


