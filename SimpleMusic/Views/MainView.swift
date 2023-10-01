//
//  MainView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/28/23.
//

import SwiftUI
import KeychainAccess
import HTTPTypes
import HTTPTypesFoundation


enum SelectedTab {
    case home
    case accounts
}


struct MainView: View {
    @State private var currentTab: SelectedTab = .home
    
    var body: some View {
        TabView(selection: $currentTab) {
            ContentView(currentTab: $currentTab)
                .tabItem {
                    Label("Playlists", systemImage: "play.square.stack.fill")
                }
                .tag(SelectedTab.home)
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "person.2.fill")
                }
                .tag(SelectedTab.accounts)
        }
    }
}

//#Preview {
//    MainView()
//}
