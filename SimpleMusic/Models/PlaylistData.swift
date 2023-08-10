//
//  PlaylistData.swift
//  SimpleMusic
//
//  Created by John Graham on 8/3/23.
//

import Foundation
import SwiftData

@Model
class PlaylistData {
    var name: String
    var amid: String
    var spid: String
    var coverImage: String?
    
    init(name: String, amid: String, spid: String, coverImage: String?) {
        self.name = name
        self.amid = amid
        self.spid = spid
        self.coverImage = coverImage ?? ""
    }
}
