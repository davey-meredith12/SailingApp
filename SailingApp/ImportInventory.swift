//
//  ImportInventory.swift
//  SailingApp
//
//  Created by David Meredith on 11/9/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// Reads the CSV the user picked, builds an InventoryItem for each row,
// and adds it to the given boat.
// Expected header:
// Name,Type,Amount,Low Stock Warning,Location,Has Expiration,Expiration Date,Notes
func importInventory(from url: URL, boat: Boat, context: ModelContext) {
    // Needed for files the user picks (outside your app's sandbox)
    let didAccess = url.startAccessingSecurityScopedResource()
    defer { if didAccess { url.stopAccessingSecurityScopedResource() } }

    guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
        print("Couldn't read file")
        return
    }

    // For converting "3-Nov-27" into a Date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d-MMM-yy"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    let lines = contents
        .components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

    var importedCount = 0

    // dropFirst() skips the header row
    for line in lines.dropFirst() {
        // omittingEmptySubsequences: false keeps blank fields (like empty Notes)
        let columns = line
            .split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }

        guard columns.count >= 8 else {
            print("Skipping malformed row: \(line)")
            continue
        }

        let name          = columns[0]                        // "Canned Beans"
        let typeName      = columns[1]                        // "Food"
        let amount        = Int(columns[2]) ?? 0              // 2
        let lowStock      = Int(columns[3]) ?? 0              // 2
        let locationName  = columns[4]                        // "Right Kitchen Cabinet"
        let hasExpiration = columns[5].uppercased() == "TRUE"
        let expiration    = hasExpiration ? dateFormatter.date(from: columns[6]) : nil
        let notes         = columns[7]                        // often ""

        // Use the boat's existing type/location if the name matches,
        // otherwise create it and add it to the boat.
        let type = findOrCreateType(named: typeName, boat: boat, context: context)
        let location = findOrCreateLocation(named: locationName, boat: boat, context: context)

        // ASSUMPTION: InventoryItem has an init with these labels, in this
        // order. Adjust to match your real initializer.
        let item = InventoryItem(
            name: name,
            type: type,
            amount: amount,
            minimumAmount: lowStock,
            location: location,
            expiration: expiration,
            notes: notes,
            boat: boat
        )
        context.insert(item)
    }

    do {
        try context.save()
        print("Imported items")
    } catch {
        print("Couldn't save imported items: \(error.localizedDescription)")
    }
}

// MARK: - Lookups

// Uses boat.inventoryTypes and InventoryType(name:boat:).
func findOrCreateType(named name: String, boat: Boat, context: ModelContext) -> InventoryType? {
    guard !name.isEmpty else { return nil }

    if let existing = boat.inventoryTypes.first(where: {
        $0.name.caseInsensitiveCompare(name) == .orderedSame
    }) {
        return existing
    }

    // Setting `boat` links it both ways, so no append is needed.
    let newType = InventoryType(name: name, boat: boat)
    context.insert(newType)
    return newType
}

// Uses boat.storageLocations and StorageLocation(name:boat:).
func findOrCreateLocation(named name: String, boat: Boat, context: ModelContext) -> StorageLocation? {
    guard !name.isEmpty else { return nil }

    if let existing = boat.storageLocations.first(where: {
        $0.name.caseInsensitiveCompare(name) == .orderedSame
    }) {
        return existing
    }

    // Setting `boat` links it both ways, so no append is needed.
    let newLocation = StorageLocation(name: name, boat: boat)
    context.insert(newLocation)
    return newLocation
}
