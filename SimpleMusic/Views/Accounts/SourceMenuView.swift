//
//  SourceMenuView.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

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
