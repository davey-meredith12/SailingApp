//
//  InventoryItem.swift
//  SailingApp
//
//  Created by David Meredith on 8/5/26.
//

import Foundation
import SwiftData

enum InventoryType: String, Codable, CaseIterable {
    case safetyEquipment = "Safety Equipment"
    case tools = "Tools"
    case spareParts = "Spare Parts"
    case engineSupplies = "Engine Supplies"
    case cleaningSupplies = "Cleaning Supplies"
    case galley = "Galley"
    case food = "Food"
    case drinks = "Drinks"
    case medicalSupplies = "Medical Supplies"
    case misc = "Misc"
}

@Model
final class InventoryItem {
    var name: String
    var type: InventoryType
    var amount: Int
    var minimumAmount: Int
    var location: String
    var expiration: Date?
    var notes: String
    var boat: Boat?

    init(
        name: String,
        type: InventoryType,
        amount: Int = 1,
        minimumAmount: Int = 0,
        location: String = "",
        expiration: Date? = nil,
        notes: String = "",
        boat: Boat?
    ) {
        self.name = name
        self.type = type
        self.amount = amount
        self.minimumAmount = minimumAmount
        self.location = location
        self.expiration = expiration
        self.notes = notes
        self.boat = boat
    }

    var isLow: Bool {
        amount <= minimumAmount
    }
    
    var isExpired: Bool {
        guard let expiration else {return false}
        return Calendar.current.startOfDay(for: expiration) < Calendar.current.startOfDay(for: .now)
    }
    
    var isCloseToExpiring: Bool {
        return isCloseToExpiring(numWarningDays: 7)
    }
    
    func isCloseToExpiring(numWarningDays: Int) -> Bool{
        if isExpired {return false}
        
        if let days = daysUntilExpiration {
            return days <= numWarningDays
        }
        
        return false
    }
    
    var daysUntilExpiration: Int? {
        guard let expiration else {return nil}
        let today = Calendar.current.startOfDay(for: .now)
        let components = Calendar.current.dateComponents([.day], from: today, to: expiration)
        
        if let days = components.day{
            return days
        }
        return nil
    }
    
    
}
