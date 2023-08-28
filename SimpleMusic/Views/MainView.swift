//
//  MainView.swift
//  SimpleMusic
//
//  Created by John Graham on 7/28/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var dq = DispatchQueue(label: "John-Graham.SimpleMusic")
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("ContentView", systemImage: "network")
                }
            SettingsView()
                .tabItem {
                    Label("SettingsView", systemImage: "gear")
                }
        }
    }
}

//#Preview {
//    MainView()
//}
