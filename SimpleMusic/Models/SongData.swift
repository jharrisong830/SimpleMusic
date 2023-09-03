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

extension SongData {
    static let emptySong = SongData(name: "", artists: [], albumName: "", albumArtists: [], isrc: "", amid: "", spid: "", coverImage: "")
}
