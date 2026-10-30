//
//  BoatLocationForm.swift
//  SailingApp
//
//  Created by David Meredith on 10/29/26.
//

import SwiftUI
import SwiftData

struct StorageLocationForm: View {
    @Bindable var location: StorageLocation
    
    var body: some View{
        Form {
            Section("Name") {
                HStack{
                    Text("Name:")
                    TextField("Name", text: $location.name)
                }
            }
        }
    }
}
