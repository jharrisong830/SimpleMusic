//
//  PlaylistSongListView.swift
//  SimpleMusic
//
//  Created by John Graham on 11/24/23.
//

import SwiftUI

struct PlaylistSongListView: View {
    @Bindable var playlist: PlaylistData
    
    var body: some View {
        if playlist.songs.isEmpty {
            ProgressView()
        }
        else {
            SongListView(songs: $playlist.songs)
        }
    }
}


