//
//  UserSettings.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

import Foundation
import SwiftData



struct UserSettingsMigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [UserSettingsSchemaV2.self, UserSettingsSchemaV1.self]
    static let stages: [MigrationStage] = [v1Tov2]
    
    static let v1Tov2 = MigrationStage.lightweight(fromVersion: UserSettingsSchemaV1.self, toVersion: UserSettingsSchemaV2.self)
}


struct UserSettingsSchemaV2: VersionedSchema {
    static let models: [any PersistentModel.Type] = [UserSettings.self]
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    
    @Model
    class UserSettings {
        var spotifyActive: Bool
        var youtubeActive: Bool?
        
        var noServicesActive: Bool {
            !self.spotifyActive && !(self.youtubeActive ?? false)
        }
        
        init(spotifyActive: Bool = false, youtubeActive: Bool? = false) {
            self.spotifyActive = spotifyActive
            self.youtubeActive = youtubeActive
        }
    }
}


typealias UserSettings = UserSettingsSchemaV2.UserSettings


struct UserSettingsSchemaV1: VersionedSchema {
    static let models: [any PersistentModel.Type] = [UserSettings.self]
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    @Model
    class UserSettings {
        var spotifyActive: Bool
        
        var noServicesActive: Bool {
            !self.spotifyActive
        }
        
        init(spotifyActive: Bool = false) {
            self.spotifyActive = spotifyActive
        }
    }
}
