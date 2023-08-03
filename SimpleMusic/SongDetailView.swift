//
//  SongDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI
import MusicKit

struct SongDetailView: View {
    @Bindable var song: SongData
    
    var body: some View {
        List {
            HStack {
                Text("Title")
                Spacer()
                Text(song.name)
            }
            HStack {
                Text("Artist")
                Spacer()
                Text(song.artists[0])
            }
            HStack {
                Text("Album")
                Spacer()
                Text(song.albumName)
            }
            HStack {
                Text("ISRC")
                Spacer()
                Text(song.isrc)
            }
            Button(action: {
                Task {
                    
                    
                }
            }, label: {
                Text("Apple Music API Search")
            })
        }
    }
}

//#Preview {
//    SongDetailView(song: SampleSongData.contents[0])
//}
