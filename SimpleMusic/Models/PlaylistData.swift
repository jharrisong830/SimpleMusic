//
//  PlaylistData.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import Foundation
import SwiftData

enum PlaylistSourcePlatform: Codable {
    case spotify
    case appleMusic
    case youTube
}

struct PlaylistDataMigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [PlaylistDataSchemaV2.self, PlaylistDataSchemaV1.self]
    static let stages: [MigrationStage] = [v1Tov2]
    
    static let v1Tov2 = MigrationStage.lightweight(fromVersion: PlaylistDataSchemaV1.self, toVersion: PlaylistDataSchemaV2.self)
}


struct PlaylistDataSchemaV2: VersionedSchema {
    static let models: [any PersistentModel.Type] = [PlaylistData.self]
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    @Model
    class PlaylistData {
        var name: String
        var amid: String
        var spid: String
        var ytid: String?
        var coverImage: String?
        var sourcePlatform: PlaylistSourcePlatform
        
        init(name: String, amid: String, spid: String, ytid: String?, coverImage: String?, sourcePlatform: PlaylistSourcePlatform) {
            self.name = name
            self.amid = amid
            self.spid = spid
            self.ytid = ytid
            self.coverImage = coverImage ?? ""
            self.sourcePlatform = sourcePlatform
        }
    }
}

typealias PlaylistData = PlaylistDataSchemaV2.PlaylistData



struct PlaylistDataSchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [PlaylistData.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model
    class PlaylistData {
        var name: String
        var amid: String
        var spid: String
        var coverImage: String?
        var sourcePlatform: PlaylistSourcePlatform
        
        init(name: String, amid: String, spid: String, coverImage: String?, sourcePlatform: PlaylistSourcePlatform) {
            self.name = name
            self.amid = amid
            self.spid = spid
            self.coverImage = coverImage ?? ""
            self.sourcePlatform = sourcePlatform
        }
    }
}

