//
//  ConfirmTransferToSpotifySheet.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

import SwiftUI

struct ConfirmTransferToSpotifySheet: View {
    @Bindable var playlist: PlaylistData
    @Binding var appleSongs: [SongData]
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("#TODO: Match Apple songs to Spotify")
            .fontDesign(.monospaced)
            .bold()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Done")
                    }
                }
            }
    }
}

