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
    case settings
}


struct MainView: View {
    @State private var currentTab: SelectedTab = .home
    
    var body: some View {
        TabView(selection: $currentTab) {
            ContentView(currentTab: $currentTab)
                .tabItem {
                    Label("ContentView", systemImage: "network")
                }
                .tag(SelectedTab.home)
            SettingsView()
                .tabItem {
                    Label("SettingsView", systemImage: "gear")
                }
                .tag(SelectedTab.settings)
        }
    }
}

//#Preview {
//    MainView()
//}
