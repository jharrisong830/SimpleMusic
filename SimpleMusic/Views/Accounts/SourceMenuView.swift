//
//  SourceMenuView.swift
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

struct SourceMenuView: View {
    @Query private var userSettings: [UserSettings]
    
    @Binding var isPresentingSpotify: Bool
    @Binding var isPresentingAppleMusic: Bool
    @Binding var isPresentingYouTube: Bool
    @Binding var currentTab: SelectedTab
    
    var body: some View {
        Menu {
            if userSettings == [] || (userSettings[0].noServicesActive && (MusicAuthorization.currentStatus != .authorized)) {
                Button {
                    withAnimation {
                        currentTab = .accounts
                    }
                } label: {
                    Label("Add services in Accounts.", systemImage: "xmark.circle.fill")
                }
            }
            else {
                if userSettings[0].spotifyActive {
                    Button {
                        withAnimation {
                            isPresentingSpotify = true
                        }
                    } label: {
                        Label("From Spotify", image: "Spotify Logo")
                    }
                }
                if MusicAuthorization.currentStatus == .authorized {
                    Button {
                        withAnimation {
                            isPresentingAppleMusic = true
                        }
                    } label: {
                        Label("From Apple Music", image: "AM Logo")
                    }
                }
                if userSettings[0].youtubeActive ?? false {
                    Button {
                        withAnimation {
                            isPresentingYouTube = true
                        }
                    } label: {
                        Label("From YouTube", systemImage: "network")
                    }
                }
            }
        } label: {
            Label("Add Item", systemImage: "plus")
        }
    }
}
