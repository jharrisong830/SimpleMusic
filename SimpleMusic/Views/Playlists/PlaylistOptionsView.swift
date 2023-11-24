//
//  PlaylistOptionsView.swift
//  SimpleMusic
//
//  Created by John Graham on 11/24/23.
//

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
                            .foregroundStyle(.green)
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

