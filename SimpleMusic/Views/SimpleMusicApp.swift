//
//  SimpleMusicApp.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI
import SwiftData

typealias JSONObject = Dictionary<String, Any>

@main
struct SimpleMusicApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [PlaylistData.self, SongData.self])
    }
}
