//
//  SongDetailView.swift
//  SimpleMusic
//
//  Created by John Graham on 8/11/23.
//

import SwiftUI

struct SongDetailView: View {
    let song: SongData
    
    var body: some View {
        List {
            Text(song.name)
            Text(song.artists[0])
            Text(song.isrc)
        }
        .navigationTitle(song.name)
    }
}

//#Preview {
//    SongDetailView()
//}
