//
//  Boat.swift
//  SailingApp
//
//  Created by David Meredith on 8/7/26.
//

import SwiftData
import Foundation


@Model
final class Boat {
    var name: String
    var make: String
    var model: String
    var year: Int
    
    var engineInfo: String
    
    var fuelTankCapacity: Int
    var waterTankCapacity: Int
    var holdingTankCapacity: Int
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryItem.boat)
        var inventory: [InventoryItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \StorageLocation.boat)
        var storageLocations: [StorageLocation] = []
    
    @Relationship(deleteRule: .cascade, inverse: \InventoryType.boat)
        var inventoryTypes: [InventoryType] = []
    
    static let defaultInventoryTypes = [
            "Safety Equipment",
            "Tools",
            "Spare Parts",
            "Engine Supplies",
            "Cleaning Supplies",
            "Galley",
            "Food",
            "Drinks",
            "Medical Supplies",
            "Misc"
        ]
    
    init(name: String = "",
         make: String = "",
         model: String = "",
         year: Int = 0,
         engineInfo: String = "",
         fuelTankCapacity: Int = 0,
         waterTankCapacity: Int = 0,
         holdingTankCapacity: Int = 0
        ) {
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.engineInfo = engineInfo
        self.fuelTankCapacity = fuelTankCapacity
        self.waterTankCapacity = waterTankCapacity
        self.holdingTankCapacity = holdingTankCapacity
        
        
    }
    
    func addDefaultInventoryTypes(){
        for name in Self.defaultInventoryTypes{
            //creation adds the type to the boat
            _ = InventoryType(name: name, boat: self)
        }
    }
    
    
}
