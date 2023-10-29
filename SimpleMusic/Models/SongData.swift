//
//  SongData.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import Foundation
import SwiftData

enum MatchState: Codable {
    case notDetermined
    case failed
    case successful
}



struct SongDataMigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [SongDataSchemaV2.self, SongDataSchemaV1.self]
    static let stages: [MigrationStage] = [v1Tov2]
    
    static let v1Tov2 = MigrationStage.lightweight(fromVersion: SongDataSchemaV1.self, toVersion: SongDataSchemaV2.self)
}


struct SongDataSchemaV2: VersionedSchema {
    static let models: [any PersistentModel.Type] = [SongData.self]
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    @Model
    class SongData {
        var name: String
        var artists: [String]
        var albumName: String
        var albumArtists: [String]
        var isrc: String
        var amid: String
        var spid: String
        var ytid: String?
        var coverImage: String?
        var matchState: MatchState
        
        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String, ytid: String?, coverImage: String?, matchState: MatchState = .notDetermined) {
            self.name = name
            self.artists = artists
            self.albumName = albumName
            self.albumArtists = albumArtists
            self.isrc = isrc
            self.amid = amid
            self.spid = spid
            self.ytid = ytid
            self.coverImage = coverImage ?? ""
            self.matchState = matchState
        }
    }
}

typealias SongData = SongDataSchemaV2.SongData



struct SongDataSchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [SongData.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model
    class SongData {
        var name: String
        var artists: [String]
        var albumName: String
        var albumArtists: [String]
        var isrc: String
        var amid: String
        var spid: String
        var coverImage: String?
        var matchState: MatchState
        
        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String, coverImage: String?, matchState: MatchState = .notDetermined) {
            self.name = name
            self.artists = artists
            self.albumName = albumName
            self.albumArtists = albumArtists
            self.isrc = isrc
            self.amid = amid
            self.spid = spid
            self.coverImage = coverImage ?? ""
            self.matchState = matchState
        }
    }
}






extension SongData {
    static let emptySong = SongData(name: "", artists: [], albumName: "", albumArtists: [], isrc: "", amid: "", spid: "", ytid: nil, coverImage: "")
}
