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
    @State private var navPath: [PlaylistData] = []
    
    func isFirstLaunch() {
//        let userDefaults = UserDefaults.standard
//        if userDefaults.object(forKey: "simpleMusic_firstLaunch") == nil {
//            firstLaunch = true
//        }
        firstLaunch = userSettings == []
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                ForEach(playlists) { playlist in
                    NavigationLink(value: playlist) {
                        HStack {
                            Text(playlist.name)
                            Spacer()
                            Image("Spotify Logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
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
                    SourceMenuView(isPresentingSpotify: $isPresentingSpotify, isPresentingAppleMusic: $isPresentingAppleMusic, currentTab: $currentTab)
                }
            }
            .navigationTitle("Home")
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
