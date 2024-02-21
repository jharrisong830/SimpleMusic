//
//  PlaylistOptionsView.swift
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
import SwiftData
import MusicKit

struct PlaylistOptionsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var userSettings: [UserSettings]
    
    @Bindable var playlist: PlaylistData
    
    @Binding var navPath: [PlaylistData]
    @Binding var isTransferingToSpotify: Bool
    @Binding var isTransferingToApple: Bool
    
    
    var body: some View {
        Section {
            switch playlist.platform {
            case.appleMusic:
                if userSettings[0].spotifyActive {
                    Button {
                        isTransferingToSpotify = true
                    } label: {
                        Text("Transfer to Spotify")
                            .foregroundStyle(Color("SpotifyGreen"))
                    }
                }
            case .spotify:
                if MusicAuthorization.currentStatus == .authorized {
                    Button {
                        isTransferingToApple = true
                    } label: {
                        Text("Transfer to Apple Music")
                            .foregroundStyle(.pink)
                    }
                }
            default:
                Image(systemName: "network")
            }
            Button {
                withAnimation {
                    modelContext.delete(playlist)
                    _ = navPath.popLast()
                }
            } label: {
                Text("Remove")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Options")
        }
    }
}

