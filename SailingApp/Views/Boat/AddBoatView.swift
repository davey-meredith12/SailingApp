//
//  AddBoatView.swift
//  SailingApp
//
//  Created by David Meredith on 8/7/26.
//

import SwiftUI
import SwiftData

struct AddBoatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    @State var boat: Boat = Boat()
    
    var body: some View {
        
        AddItemSheet(title: "Add Boat"){
            BoatForm(boat: boat)
        } onAdd:{
            modelContext.insert(boat)
            boatStore.currentBoat = boat
        }
        
        
        
        
        
        
        
//        NavigationStack{
//            BoatForm(boat: boat)
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
//        .navigationTitle("Add Boat")
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
    AddBoatView()
}
