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
// Fields may be wrapped in double quotes (with "" for a literal quote), so
// commas and line breaks are allowed inside a field.
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

    let rows = parseCSV(contents)

    var importedCount = 0

    // dropFirst() skips the header row
    for columns in rows.dropFirst() {
        guard columns.count >= 8 else {
            print("Skipping malformed row: \(columns.joined(separator: ","))")
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

        //Create item
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
        importedCount += 1
    }

    do {
        try context.save()
        print("Imported \(importedCount) items")
    } catch {
        print("Couldn't save imported items: \(error.localizedDescription)")
    }
}

// MARK: - CSV parsing

// Parses CSV text into rows of fields. Handles:
// - quoted fields containing commas, quotes ("") and line breaks
// - \n, \r and \r\n line endings
// - a leading byte-order mark
// - blank lines (skipped)
// Unquoted fields are trimmed of surrounding spaces; quoted fields are kept as-is.
func parseCSV(_ text: String) -> [[String]] {
    var rows: [[String]] = []
    var row: [String] = []
    var field = ""
    var inQuotes = false
    var fieldWasQuoted = false

    func endField() {
        row.append(fieldWasQuoted ? field : field.trimmingCharacters(in: .whitespaces))
        field = ""
        fieldWasQuoted = false
    }

    let chars = Array(text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text)
    var i = 0
    while i < chars.count {
        let ch = chars[i]

        if inQuotes {
            if ch == "\"" {
                if i + 1 < chars.count && chars[i + 1] == "\"" {
                    field.append("\"")      // "" -> literal quote
                    i += 1
                } else {
                    inQuotes = false        // closing quote
                }
            } else {
                field.append(ch)            // commas and newlines are literal here
            }
        } else {
            switch ch {
            case "\"" where field.trimmingCharacters(in: .whitespaces).isEmpty && !fieldWasQuoted:
                inQuotes = true             // opening quote at start of field
                fieldWasQuoted = true
                field = ""
            case ",":
                endField()
            case "\n", "\r", "\r\n":        // Swift treats "\r\n" as one Character
                endField()
                rows.append(row)
                row = []
            default:
                field.append(ch)
            }
        }
        i += 1
    }

    // Last row if the file doesn't end with a newline
    if !field.isEmpty || fieldWasQuoted || !row.isEmpty {
        endField()
        rows.append(row)
    }

    // Drop blank lines
    return rows.filter { !($0.count == 1 && $0[0].isEmpty) }
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
