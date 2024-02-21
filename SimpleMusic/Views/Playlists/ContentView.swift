//
//  ContentView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI
import SwiftData
import MusicKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var playlists: [PlaylistData]
    @Query private var userSettings: [UserSettings]
    
    @Binding var currentTab: SelectedTab
    
    @State private var firstLaunch = false
    @State private var isPresentingSpotify = false
    @State private var isPresentingAppleMusic = false
    @State private var isPresentingYouTube = false
    @State private var navPath: [PlaylistData] = []
    
    func isFirstLaunch() {
        firstLaunch = userSettings == []
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            if userSettings == [] || userSettings[0].noServicesActive || MusicAuthorization.currentStatus != .authorized {
                NoServicesView(currentTab: $currentTab)
                .navigationTitle("Playlists")
            }
            else {
                if playlists.isEmpty {
                    Text("No playlists are added. Click the \(Image(systemName: "plus")) to import a playlist.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
                            ToolbarItem {
                                SourceMenuView(isPresentingSpotify: $isPresentingSpotify, isPresentingAppleMusic: $isPresentingAppleMusic, isPresentingYouTube: $isPresentingYouTube, currentTab: $currentTab)
                            }
                        }
                        .navigationTitle("Playlists")
                }
                else {
                    List {
                        ForEach(playlists) { playlist in
                            NavigationLink(value: playlist) {
                                HStack {
                                    Text(playlist.name)
                                    Spacer()
                                    switch playlist.platform {
                                    case .appleMusic:
                                        Image("AM Logo")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    case .spotify:
                                        Image("Spotify Logo")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    default:
                                        Image(systemName: "network")
                                    }
                                }
                            }
                            .disabled(!userSettings[0].spotifyActive)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .navigationDestination(for: PlaylistData.self) { playlist in
                        PlaylistDetailWithOptionsView(playlist: playlist, navPath: $navPath)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem {
                            SourceMenuView(isPresentingSpotify: $isPresentingSpotify, isPresentingAppleMusic: $isPresentingAppleMusic, isPresentingYouTube: $isPresentingYouTube, currentTab: $currentTab)
                        }
                    }
                    .navigationTitle("Playlists")
                }
            }
        }
        .onAppear(perform: isFirstLaunch)
        .sheet(isPresented: $firstLaunch, content: {
            WelcomeSheet(firstLaunch: $firstLaunch)
        })
        .sheet(isPresented: $isPresentingSpotify, content: {
            ImportSpotifyPlaylistSheet(isPresented: $isPresentingSpotify)
        })
        .sheet(isPresented: $isPresentingAppleMusic, content: {
            ImportApplePlaylistSheet(isPresented: $isPresentingAppleMusic)
        })
//        .sheet(isPresented: $isPresentingYouTube, content: {
//            ImportYouTubePlaylistSheet(isPresented: $isPresentingYouTube)
//        })
    }


    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(playlists[index])
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
