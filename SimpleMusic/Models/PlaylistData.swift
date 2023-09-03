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
}

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
