//
//  WelcomeSheet.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI
import MusicKit

struct WelcomeSheet: View {
    @Binding var firstLaunch: Bool
    @Binding var musicKitStatus: MusicAuthorization.Status
    
    private struct DetailData: Identifiable {
        let title: String
        var id: String {
            self.title
        }
        let description: String
        let iconName: String
    }
    
    private let detailData = [
        DetailData(title: "Transfer Playlists with Ease", description: "SimpleMusic connects to your Apple Music and Spotify accounts to transfer playlists.", iconName: "music.note.list"),
        DetailData(title: "Matching Comes First", description: "SimpleMusic searches for exact song matches, and asks you to fill in any gaps.", iconName: "doc.on.doc.fill"),
        DetailData(title: "Your Data is Yours", description: "Rest assured that your song data will not be collected or sold.", iconName: "lock.square.stack.fill")
    ]
    
    
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Welcome to SimpleMusic")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
            ForEach(detailData) { detail in
                WelcomeDetailRow(iconName: detail.iconName, title: detail.title, description: detail.description)
            }
            Spacer()
            Button(action: {
                let userDefaults = UserDefaults.standard
                userDefaults.set(1, forKey: "simpleMusic_firstLaunch")
                userDefaults.set("NONE", forKey: "simpleMusic_settings_spotifyAcc")
                firstLaunch = false
            }, label: {
                Text("Let's go!")
            })
            .buttonStyle(ProminentButtonStyle())
            Spacer()
        }
    }
}

#Preview {
    WelcomeSheet(firstLaunch: .constant(true), musicKitStatus: .constant(MusicAuthorization.Status.authorized))
}
