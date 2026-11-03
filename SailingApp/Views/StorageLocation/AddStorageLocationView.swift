//
//  AddStorageLocationView.swift
//  SailingApp
//
//  Created by David Meredith on 10/29/26.
//

import SwiftUI
import SwiftData

struct AddStorageLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    @State var location: StorageLocation = StorageLocation(name: "", boat: nil)
    
    
    var body: some View {
        AddItemSheet(title: "Add Item"){
            StorageLocationForm(location: location)
        } onAdd: {
            location.boat = boatStore.currentBoat
            modelContext.insert(location)
        }
    }

}

#Preview {
    AddStorageLocationView()
}

