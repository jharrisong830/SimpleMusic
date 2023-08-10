//
//  SongData.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import Foundation
import SwiftData

@Model
class SongData {
    var name: String
    var artists: [String]
    var albumName: String
    var albumArtists: [String]
    var isrc: String
    var amid: String
    var spid: String
    
    init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String) {
        self.name = name
        self.artists = artists
        self.albumName = albumName
        self.albumArtists = albumArtists
        self.isrc = isrc
        self.amid = amid
        self.spid = spid
    }
}
