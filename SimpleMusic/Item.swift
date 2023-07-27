//
//  Item.swift
//  SimpleMusic
//
//  Created by John Graham on 7/27/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
