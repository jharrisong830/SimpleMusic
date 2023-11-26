//
//  Schema.swift
//  SimpleMusic
//
//  Created by John Graham on 11/24/23.
//

import Foundation
import SwiftData

struct SimpleMusicSchemaMigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [SimpleMusicSchemaV1.self]
    static let stages: [MigrationStage] = []
    
    
}


struct SimpleMusicSchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [SongDataSchemaRevV3.SongData.self, PlaylistDataSchemaRevV2.PlaylistData.self, UserSettingsSchemaV2.UserSettings.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
}
