//
//  SimpleMusicApp.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftUI
import SwiftData

@main
struct SimpleMusicApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
