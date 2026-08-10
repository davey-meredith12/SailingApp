//
//  InventoryItemForm.swift
//  SailingApp
//
//  Created by David Meredith on 8/6/26.
//

import SwiftUI
import SwiftData

struct InventoryItemForm: View{
    @Bindable var item: InventoryItem
    
    var body: some View{
        Form {
            Section("Item") {
                TextField("Name", text: $item.name)
                
                Picker("Type", selection: $item.type){
                    ForEach(InventoryType.allCases, id: \.self){type in
                        Text(type.rawValue).tag(type)
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
                TextField("Location", text: $item.location)
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
