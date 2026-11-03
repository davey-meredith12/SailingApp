//
//  InventoryItemForm.swift
//  SailingApp
//
//  Created by David Meredith on 8/6/26.
//

import SwiftUI
import SwiftData

struct InventoryItemForm: View{
    @Environment(BoatStore.self) private var boatStore
    @Bindable var item: InventoryItem
    
    var body: some View{
        Form {
            Section("Item") {
                TextField("Name", text: $item.name)
                
                Picker("Type", selection: $item.type){
                    Text("Uncategorized").tag(nil as InventoryType?)
                    
                    ForEach(boatStore.currentBoat?.inventoryTypes ?? []) {inventoryType in
                        Text(inventoryType.name).tag(inventoryType as InventoryType)
                    }
                }
                
                Stepper(value: $item.amount, in: 0...100) {
                    Text("Amount: \(item.amount)")
                }
                
                Stepper(value: $item.minimumAmount, in: 0...100) {
                    Text("Low Stock Warning: \(item.minimumAmount)")
                }
            }
            
            Section("Location"){
                Picker("Location", selection: $item.location) {
                    Text("None").tag(nil as StorageLocation?)

                    ForEach(boatStore.currentBoat?.storageLocations ?? []) { location in
                        Text(location.name).tag(location as StorageLocation?)
                    }
                }
            }
            
            Section("Expiration") {
                Toggle(
                    "Has Expiration",
                    isOn: Binding(
                        get: { item.expiration != nil },
                        set: { enabled in
                            item.expiration = enabled ? Calendar.current.startOfDay(for: Date()) : nil
                        }
                    )
                )
                
                if item.expiration != nil {
                    DatePicker(
                        "Expiration",
                        selection: Binding(
                            get: { item.expiration ?? Date() },
                            set: { item.expiration = Calendar.current.startOfDay(for: $0) }
                        ),
                        displayedComponents: .date
                    )
                }
            }
            
            Section("Notes") {
                TextField(
                    "Additional Notes",
                    text: $item.notes,
                    axis: .vertical
                )
                .lineLimit(4...8)
            }
        }
    }
}
