//
//  Item.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
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
