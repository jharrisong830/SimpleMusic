//
//  SongData.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import Foundation

class SongData: Identifiable {
    var name: String
    var artists: [String]
    var albumName: String
    var albumArtists: [String]
    var isrc: String
    var amid: String
    var spid: String
    var id: String
    var coverImage: String?
    
    init(name: String, artists: [String], albumName: String, albumArtists: [String], isrc: String, amid: String, spid: String, coverImage: String?) {
        self.name = name
        self.artists = artists
        self.albumName = albumName
        self.albumArtists = albumArtists
        self.isrc = isrc
        self.amid = amid
        self.spid = spid
        self.id = self.spid
        self.coverImage = coverImage ?? ""
    }
}
