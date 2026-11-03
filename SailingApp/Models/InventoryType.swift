//
//  InventoryType.swift
//  SailingApp
//
//  Created by David Meredith on 11/3/26.
//

//enum InventoryType: String, Codable, CaseIterable {
//    case safetyEquipment = "Safety Equipment"
//    case tools = "Tools"
//    case spareParts = "Spare Parts"
//    case engineSupplies = "Engine Supplies"
//    case cleaningSupplies = "Cleaning Supplies"
//    case galley = "Galley"
//    case food = "Food"
//    case drinks = "Drinks"
//    case medicalSupplies = "Medical Supplies"
//    case misc = "Misc"
//}

import SwiftData
import Foundation

@Model
final class InventoryType{
    var name: String
    var boat: Boat?
    
    @Relationship(deleteRule: .nullify, inverse: \InventoryItem.type)
        var items: [InventoryItem] = []
    
    init(
        name: String,
        boat: Boat?
    ) {
        self.name = name
        self.boat = boat
    }
}
