//
//  AddInventoryTypeView.swift
//  SailingApp
//
//  Created by David Meredith on 11/3/26.
//

import SwiftUI
import SwiftData

struct AddInventoryTypeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    @State var type: InventoryType = InventoryType(name: "", boat: nil)
    
    
    var body: some View {
        AddItemSheet(title: "Add Item"){
            InventoryTypeForm(type: type)
        } onAdd: {
            type.boat = boatStore.currentBoat
            modelContext.insert(type)
        }
    }

}
