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
    static let schemas: [VersionedSchema.Type] = [SongDataSchemaRevV1.self]
    static let stages: [MigrationStage] = []
}

struct SongDataSchemaRevV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [SongData.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model
    class SongData {
        var name: String
        var artists: [String]
        var albumName: String
        var albumArtists: [String]
        var isrc: String
        var platform: SourcePlatform
        var platformID: String
        var platformURL: URL?
        var coverImage: URL?
        var matchState: MatchState
        
        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, platform: SourcePlatform, platformID: String, platformURL: URL?, coverImage: URL?, matchState: MatchState = .notDetermined) {
            self.name = name
            self.artists = artists
            self.albumName = albumName
            self.albumArtists = albumArtists
            self.isrc = isrc
            self.platform = platform
            self.platformID = platformID
            self.platformURL = platformURL
            self.coverImage = coverImage
            self.matchState = matchState
        }
    }
}

typealias SongData = SongDataSchemaRevV1.SongData


extension SongData {
    static let emptySong = SongData(name: "", artists: [], albumName: "", albumArtists: [], isrc: "", platform: .none, platformID: "", platformURL: nil, coverImage: nil, matchState: .notDetermined)
    
    static let nilSong = SongData(name: "Unknown Song", artists: [], albumName: "", albumArtists: [], isrc: "", platform: .none, platformID: "", platformURL: nil, coverImage: nil, matchState: .failed)
}


struct SampleSongs { // sample data for SwiftData container
    static let sampleSongs = [
        SongData(name: "Death of a Bachelor", artists: ["Panic! At the Disco"], albumName: "Death of a Bachelor", albumArtists: ["Panic! at the Disco"], isrc: "12345", platform: .appleMusic, platformID: "appleMusic-1", platformURL: nil, coverImage: nil),
        SongData(name: "MESS U MADE", artists: ["MICHELLE"], albumName: "AFTER DINNER WE TALK DREAMS", albumArtists: ["MICHELLE"], isrc: "67890", platform: .spotify, platformID: "spotify-1", platformURL: nil, coverImage: nil)
    ]
}




//struct SongDataMigrationPlan: SchemaMigrationPlan {
//    static let schemas: [VersionedSchema.Type] = [SongDataSchemaV3.self, SongDataSchemaV2.self, SongDataSchemaV1.self]
//    static let stages: [MigrationStage] = [v1Tov2, v2Tov3]
//    
//    static let v1Tov2 = MigrationStage.lightweight(fromVersion: SongDataSchemaV1.self, toVersion: SongDataSchemaV2.self)
////    static let v2Tov3 = MigrationStage.lightweight(fromVersion: SongDataSchemaV2.self, toVersion: SongDataSchemaV3.self)
//    static let v2Tov3 = MigrationStage.custom(fromVersion: SongDataSchemaV2.self,
//                                              toVersion: SongDataSchemaV3.self,
//                                              willMigrate: { context in
//        let songs = try context.fetch(FetchDescriptor<SongDataSchemaV2.SongData>())
//        for song in songs {
//            context.delete(song)
//        }
//        for song in songs {
//            var songPlatform: SongSourcePlatform
//            if song.spid != "" {
//                songPlatform = .spotify
//            }
//            else if song.amid != "" {
//                songPlatform = .appleMusic
//            }
//            else if song.ytid != nil && song.ytid! != "" {
//                songPlatform = .youTube
//            }
//            else {
//                songPlatform = .none
//            }
//
//        }
//                                              }, didMigrate: nil)
//}
//
//
//struct SongDataSchemaV3: VersionedSchema {
//    static let models: [any PersistentModel.Type] = [SongData.self]
//    static let versionIdentifier: Schema.Version = .init(3, 0, 0)
//    
//    @Model
//    class SongData {
//        var name: String
//        var artists: [String]
//        var albumName: String
//        var albumArtists: [String]
//        var isrc: String
//        var platformID: String
//        var platformURL: URL?
//        var coverImage: URL?
//        var matchState: MatchState
//        
//        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, platformID: String, platformURL: URL?, coverImage: URL?, matchState: MatchState = .notDetermined) {
//            self.name = name
//            self.artists = artists
//            self.albumName = albumName
//            self.albumArtists = albumArtists
//            self.isrc = isrc
//            self.platformID = platformID
//            self.platformURL = platformURL
//            self.coverImage = coverImage
//            self.matchState = matchState
//        }
//    }
//}
//
////typealias SongData = SongDataSchemaV3.SongData
//
//
//struct SongDataSchemaV2: VersionedSchema {
//    static let models: [any PersistentModel.Type] = [SongData.self]
//    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
//    
//    @Model
//    class SongData {
//        var name: String
//        var artists: [String]
//        var albumName: String
//        var albumArtists: [String]
//        var isrc: String
//        var amid: String
//        var spid: String
//        var ytid: String?
//        var coverImage: String?
//        var matchState: MatchState
//        
//        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String, ytid: String?, coverImage: String?, matchState: MatchState = .notDetermined) {
//            self.name = name
//            self.artists = artists
//            self.albumName = albumName
//            self.albumArtists = albumArtists
//            self.isrc = isrc
//            self.amid = amid
//            self.spid = spid
//            self.ytid = ytid
//            self.coverImage = coverImage ?? ""
//            self.matchState = matchState
//        }
//    }
//}
//
//
//
//struct SongDataSchemaV1: VersionedSchema {
//    static let models: [any PersistentModel.Type] = [SongData.self]
//    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
//    
//    @Model
//    class SongData {
//        var name: String
//        var artists: [String]
//        var albumName: String
//        var albumArtists: [String]
//        var isrc: String
//        var amid: String
//        var spid: String
//        var coverImage: String?
//        var matchState: MatchState
//        
//        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String, coverImage: String?, matchState: MatchState = .notDetermined) {
//            self.name = name
//            self.artists = artists
//            self.albumName = albumName
//            self.albumArtists = albumArtists
//            self.isrc = isrc
//            self.amid = amid
//            self.spid = spid
//            self.coverImage = coverImage ?? ""
//            self.matchState = matchState
//        }
//    }
//}
//





//extension SongData {
//    static let emptySong = SongData(name: "", artists: [], albumName: "", albumArtists: [], isrc: "", amid: "", spid: "", ytid: nil, coverImage: "")
//}


