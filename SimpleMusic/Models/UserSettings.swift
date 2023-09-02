//
//  UserSettings.swift
//  SimpleMusic
//
//  Created by John Graham on 9/2/23.
//

import Foundation
import SwiftData

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
