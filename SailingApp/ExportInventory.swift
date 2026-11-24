//
//  ExportInventory.swift
//  SailingApp
//
//  Created by David Meredith on 11/20/26.
//

import SwiftUI
import UniformTypeIdentifiers

// Inverse of importInventory(from:boat:context:).
// Produces the header:
// Name,Type,Amount,Low Stock Warning,Location,Has Expiration,Expiration Date,Notes
func inventoryCSV(for boat: Boat) -> String {
    // Same format the importer parses, e.g. "3-Nov-27"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d-MMM-yy"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    var lines = ["Name,Type,Amount,Low Stock Warning,Location,Has Expiration,Expiration Date,Notes"]

    // Sort by type, then location, then name so the output order is
    // deterministic
    let sortedItems = boat.inventory.sorted { a, b in
        let typeA = a.type?.name ?? "", typeB = b.type?.name ?? ""
        if typeA != typeB {
            return typeA.localizedCaseInsensitiveCompare(typeB) == .orderedAscending
        }

        let locA = a.location?.name ?? "", locB = b.location?.name ?? ""
        if locA != locB {
            return locA.localizedCaseInsensitiveCompare(locB) == .orderedAscending
        }

        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }

    // Uses InventoryItem's properties (matching the init labels used by the importer).
    for item in sortedItems {
        let hasExpiration = item.expiration != nil
        let expirationText = item.expiration.map { dateFormatter.string(from: $0) } ?? ""

        let fields: [String] = [
            item.name,                       // Name
            item.type?.name ?? "",           // Type
            String(item.amount),             // Amount
            String(item.minimumAmount),      // Low Stock Warning
            item.location?.name ?? "",       // Location
            hasExpiration ? "TRUE" : "FALSE",// Has Expiration
            expirationText,                  // Expiration Date
            item.notes                       // Notes
        ]
        lines.append(fields.map(csvEscape).joined(separator: ","))
    }

    // Trailing newline after the last row
    return lines.joined(separator: "\n") + "\n"
}

// Standard CSV quoting. Fields without commas, quotes or newlines are written
// as-is, so they match what the importer reads. The importer's parseCSV
// understands this quoting, so any field round-trips.
private func csvEscape(_ field: String) -> String {
    if field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") {
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
    return field
}

// MARK: - Document wrapper for .fileExporter

struct InventoryCSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
