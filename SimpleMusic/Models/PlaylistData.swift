//
//  PlaylistData.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import Foundation
import SwiftData

enum SourcePlatform: Codable {
    case spotify
    case appleMusic
    case youTube
    case none
}

//struct PlaylistDataMigrationPlan: SchemaMigrationPlan {
//    static let schemas: [VersionedSchema.Type] = [PlaylistDataSchemaRevV1.self]
//    static let stages: [MigrationStage] = [v1RevtoV2Rev]
//    
//    static let v1RevtoV2Rev = MigrationStage.custom(fromVersion: PlaylistDataSchemaRevV1.self,
//                                                    toVersion: PlaylistDataSchemaRevV2.self,
//                                                    willMigrate: { context in
//                                                                    let playlists = try context.fetch(FetchDescriptor<PlaylistDataSchemaRevV2.PlaylistData>())
//                                                                    for playlist in playlists {
//                                                                        context.insert(PlaylistDataSchemaRevV2.PlaylistData(name: playlist.name, 
//                                                                                                                            platform: playlist.platform,
//                                                                                                                            platformID: playlist.platformID,
//                                                                                                                            platformURL: playlist.platformURL,
//                                                                                                                            coverImage: playlist.coverImage,
//                                                                                                                            songs: []))
//                                                                        context.delete(playlist)
//                                                                    }
//                                                                    try context.save()},
//                                                    didMigrate: nil)
//}


struct PlaylistDataSchemaRevV2: VersionedSchema {
    static let models: [any PersistentModel.Type] = [PlaylistData.self]
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    @Model
    class PlaylistData {
        var name: String
        var platform: SourcePlatform
        
        @Attribute(.unique)
        var platformID: String
        
        var platformURL: URL?
        var coverImage: URL?
        
        @Relationship(deleteRule: .cascade, inverse: \SongDataSchemaRevV2.SongData.playlist)
        var songs: [SongData]
        
        init(name: String, platform: SourcePlatform, platformID: String, platformURL: URL?, coverImage: URL?, songs: [SongData] = []) {
            self.name = name
            self.platform = platform
            self.platformID = platformID
            self.platformURL = platformURL
            self.coverImage = coverImage
            self.songs = songs
        }
    }
}

typealias PlaylistData = PlaylistDataSchemaRevV2.PlaylistData



struct PlaylistDataSchemaRevV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [PlaylistData.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model
    class PlaylistData {
        var name: String
        var platform: SourcePlatform
        var platformID: String
        var platformURL: URL?
        var coverImage: URL?
        
        init(name: String, platform: SourcePlatform, platformID: String, platformURL: URL?, coverImage: URL?) {
            self.name = name
            self.platform = platform
            self.platformID = platformID
            self.platformURL = platformURL
            self.coverImage = coverImage
        }
    }
}




//struct PlaylistDataMigrationPlan: SchemaMigrationPlan {
//    static let schemas: [VersionedSchema.Type] = [PlaylistDataSchemaV2.self, PlaylistDataSchemaV1.self]
//    static let stages: [MigrationStage] = [v1Tov2]
//    
//    static let v1Tov2 = MigrationStage.lightweight(fromVersion: PlaylistDataSchemaV1.self, toVersion: PlaylistDataSchemaV2.self)
//}


//struct PlaylistDataSchemaV2: VersionedSchema {
//    static let models: [any PersistentModel.Type] = [PlaylistData.self]
//    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
//    
//    @Model
//    class PlaylistData {
//        var name: String
//        var amid: String
//        var spid: String
//        var ytid: String?
//        var coverImage: String?
//        var sourcePlatform: PlaylistSourcePlatform
//        
//        init(name: String, amid: String, spid: String, ytid: String?, coverImage: String?, sourcePlatform: PlaylistSourcePlatform) {
//            self.name = name
//            self.amid = amid
//            self.spid = spid
//            self.ytid = ytid
//            self.coverImage = coverImage ?? ""
//            self.sourcePlatform = sourcePlatform
//        }
//    }
//}
//
//typealias PlaylistData = PlaylistDataSchemaV2.PlaylistData
//
//
//
//struct PlaylistDataSchemaV1: VersionedSchema {
//    static let models: [any PersistentModel.Type] = [PlaylistData.self]
//    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
//    
//    @Model
//    class PlaylistData {
//        var name: String
//        var amid: String
//        var spid: String
//        var coverImage: String?
//        var sourcePlatform: PlaylistSourcePlatform
//        
//        init(name: String, amid: String, spid: String, coverImage: String?, sourcePlatform: PlaylistSourcePlatform) {
//            self.name = name
//            self.amid = amid
//            self.spid = spid
//            self.coverImage = coverImage ?? ""
//            self.sourcePlatform = sourcePlatform
//        }
//    }
//}
//
