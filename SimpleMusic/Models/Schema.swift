//
//  Schema.swift
//  Copyright (C) 2024  John Graham
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import SwiftData

struct SimpleMusicSchemaMigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [SimpleMusicSchema_v1_0_0.self]
    static let stages: [MigrationStage] = []
}

enum MatchState: Codable {
    case successful
    case failed
    case notDetermined
}

enum SourcePlatform: Codable {
    case spotify
    case appleMusic
    case youTube
    case none
}


typealias SongData = SimpleMusicSchema_v1_0_0.SongData
typealias PlaylistData = SimpleMusicSchema_v1_0_0.PlaylistData
typealias UserSettings = SimpleMusicSchema_v1_0_0.UserSettings


struct SimpleMusicSchema_v1_0_0: VersionedSchema {
    static let models: [any PersistentModel.Type] = [SongData.self, PlaylistData.self, UserSettings.self]
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
        var playlist: PlaylistData?
        var index: Int
        var matchState: MatchState
        
        init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, platform: SourcePlatform, platformID: String, platformURL: URL?, coverImage: URL?, playlist: PlaylistData?, index: Int, matchState: MatchState = .notDetermined) {
            self.name = name
            self.artists = artists
            self.albumName = albumName
            self.albumArtists = albumArtists
            self.isrc = isrc
            self.platform = platform
            self.platformID = platformID
            self.platformURL = platformURL
            self.coverImage = coverImage
            self.playlist = playlist
            self.index = index
            self.matchState = matchState
        }
    }
    
    
    @Model
    class PlaylistData {
        var name: String
        var platform: SourcePlatform
        
        @Attribute(.unique)
        var platformID: String
        
        var platformURL: URL?
        var coverImage: URL?
        
        @Relationship(deleteRule: .cascade, inverse: \SongData.playlist)
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


extension SongData {
    static let emptySong = SongData(name: "", artists: [], albumName: "", albumArtists: [], isrc: "", platform: .none, platformID: "", platformURL: nil, coverImage: nil, playlist: nil, index: 0, matchState: .notDetermined)
    
    static let nilSong = SongData(name: "Unknown Song", artists: [], albumName: "", albumArtists: [], isrc: "", platform: .none, platformID: "", platformURL: nil, coverImage: nil, playlist: nil, index: 0, matchState: .failed)
    
    
    static let sampleSongs = [
        SongData(name: "Death of a Bachelor", artists: ["Panic! At the Disco"], albumName: "Death of a Bachelor", albumArtists: ["Panic! at the Disco"], isrc: "12345", platform: .appleMusic, platformID: "appleMusic-1", platformURL: nil, coverImage: nil, playlist: nil, index: 0),
        SongData(name: "MESS U MADE", artists: ["MICHELLE"], albumName: "AFTER DINNER WE TALK DREAMS", albumArtists: ["MICHELLE"], isrc: "67890", platform: .spotify, platformID: "spotify-1", platformURL: nil, coverImage: nil, playlist: nil, index: 0)
    ]
}
