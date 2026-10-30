//
//  StorageLocation.swift
//  SailingApp
//
//  Created by David Meredith on 10/29/26.
//

import SwiftData
import Foundation

@Model
final class StorageLocation{
    var name: String
    var boat: Boat?
    
    @Relationship(deleteRule: .nullify, inverse: \InventoryItem.location)
        var items: [InventoryItem] = []
    
    init(
        name: String,
        boat: Boat?
    ) {
        self.name = name
        self.boat = boat
    }
}
