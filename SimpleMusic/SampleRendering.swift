//
//  SampleRendering.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import SwiftData

struct SampleSongData {
    static var contents: [SongData] = [
        SongData(name: "Death of a Bachelor", artists: ["Panic! At the Disco"], albumName: "Death of a Bachelor", albumArtists: ["Panic! At the Disco"], isrc: "USAT21503696", amid: "", spid: ""),
        SongData(name: "FIRE ESCAPE", artists: ["MICHELLE"], albumName: "AFTER DINNER WE TALK DREAMS", albumArtists: ["MICHELLE"], isrc: "USAT21503696", amid: "", spid: "")
    ]
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: SongData.self, ModelConfiguration(inMemory: true)
        )
        for song in SampleSongData.contents {
            container.mainContext.insert(song)
        }
        return container
    } catch {
        fatalError("Failed to create sample container")
    }
}()
