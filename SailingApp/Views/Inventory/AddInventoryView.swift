//
//  AddInventoryView.swift
//  SailingApp
//
//  Created by David Meredith on 8/6/26.
//

import SwiftUI
import SwiftData

struct AddInventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    @State var item: InventoryItem = InventoryItem(name: "", type: InventoryType.misc, boat: nil)
    
    var body: some View {
        
        AddItemSheet(title: "Add Item"){
            InventoryItemForm(item: item)
        } onAdd: {
            item.boat = boatStore.currentBoat
            modelContext.insert(item)
        }
        
        
        
        
        
        
        
        
//        NavigationStack{
//            InventoryItemForm(item: item)
//        }
//        .safeAreaInset(edge: .bottom) {
//            HStack{
//                Spacer()
//                
//                Button {
//                    addItem()
//                } label:{
//                    Label("Add", systemImage: "plus")
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.large)
//                .padding(.horizontal)
//            }
//            
//        }
//        .navigationTitle("Add Item")
//        .toolbar{
//            ToolbarItem(placement: .topBarTrailing){
//                Button(){
//                    dismiss()
//                }label:{
//                    Image(systemName: "xmark")
//                }
//            }
//        }
    }

}

#Preview {
    AddInventoryView()
}

