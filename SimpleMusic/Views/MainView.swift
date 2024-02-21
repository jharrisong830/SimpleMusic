//
//  MainView.swift
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
