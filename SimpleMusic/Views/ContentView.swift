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
    
    @State private var firstLaunch = false
    @State private var musicKitStatus = MusicAuthorization.Status.notDetermined
    @State private var isPresented = false
    
    func isFirstLaunch() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "simpleMusic_firstLaunch") == nil {
            firstLaunch = true
        }
    }

    var body: some View {
        NavigationStack {
            if musicKitStatus == .denied { // TODO: should be .notDetermined
                VStack {
                    Text("We need access to your music library first.")
                        .font(.title3).bold()
                    Button(action: {
                        Task {
                            let status = await MusicAuthorization.request()
                            musicKitStatus = status
                        }
                    }, label: {
                        Text("Connect to Apple Music")
                    })
                    .buttonStyle(ProminentButtonStyle())
                }
                .navigationTitle("Home")
            }
            else if musicKitStatus == .notDetermined {
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink(playlist.name, destination: PlaylistDetailView(playlist: playlist))
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: {isPresented = true}) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .navigationTitle("Home")
            }
            else {
                Text("Enable Music Library Access in Settings.")
                    .font(.title3).bold()
                    .navigationTitle("Home")
            }
        }
        .onAppear(perform: isFirstLaunch)
        .sheet(isPresented: $firstLaunch, content: {
            WelcomeSheet(firstLaunch: $firstLaunch)
        })
        .sheet(isPresented: $isPresented, content: {
            ImportSpotifyPlaylistSheet(isPresented: $isPresented)
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

#Preview {
    ContentView()
}
