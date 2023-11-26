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
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SongData.self, PlaylistData.self, UserSettings.self, migrationPlan: SimpleMusicSchemaMigrationPlan.self, configurations: ModelConfiguration())
        } catch {
            fatalError("could not initialize container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(container)
    }
}
