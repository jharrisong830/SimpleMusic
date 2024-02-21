//
//  WelcomeSheet.swift
//  Copyright (C) 2024  John Graham
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI
import KeychainAccess

struct WelcomeSheet: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var firstLaunch: Bool
    
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
    
    private let keychain = Keychain(service: "John-Graham.SimpleMusic.APIKeyStore")
    
    
    
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
            Button {
                withAnimation {
                    modelContext.insert(UserSettings())
    //                let userDefaults = UserDefaults.standard
    //                userDefaults.set(1, forKey: "simpleMusic_firstLaunch")
                    keychain["access_token"] = nil
                    keychain["refresh_token"] = nil
                    firstLaunch = false
                }
            } label: {
                Text("Let's go!")
            }
            .buttonStyle(ProminentButtonStyle())
            Spacer()
        }
    }
}

//#Preview {
//    WelcomeSheet(firstLaunch: .constant(true))
//}
