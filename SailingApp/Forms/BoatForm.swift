//
//  BoatForm.swift
//  SailingApp
//
//  Created by David Meredith on 8/7/26.
//

import SwiftUI
import SwiftData

struct BoatForm: View {
    @Bindable var boat: Boat
    
    var body: some View{
        Form {
            Section("Model") {
                
                HStack{
                    Text("Name:")
                    TextField("Name", text: $boat.name)
                }
                
                HStack{
                    Text("Make:")
                    TextField("Make", text: $boat.make)
                }
                
                HStack{
                    Text("Model:")
                    TextField("Model", text: $boat.model)
                }
                
                HStack{
                    Text("Year:")
                    TextField("Year", value: $boat.year, format: .number.grouping(.never))
                        .keyboardType(.numberPad)
                }
            }
            
            Section("Engine"){
                HStack{
                    Text("Engine: ")
                    TextField("Engine", text: $boat.engineInfo)
                }
                
            }
            
            Section("Tank Capacities"){
                
                HStack{
                    Text("Fuel Capacity:")
                    TextField("Fuel Capacity", value: $boat.fuelTankCapacity, format: .number)
                        .keyboardType(.numberPad)
                }
                
                HStack{
                    Text("Water Capacity:")
                    TextField("Water Capacity", value: $boat.waterTankCapacity, format: .number)
                        .keyboardType(.numberPad)
                }
                
                HStack{
                    Text("Holding Capacity:")
                    TextField("Holding Capacity", value: $boat.holdingTankCapacity, format: .number)
                        .keyboardType(.numberPad)
                }
            }
        }
    }
}

