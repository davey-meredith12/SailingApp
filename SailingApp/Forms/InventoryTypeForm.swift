//
//  InventoryTypeForm.swift
//  SailingApp
//
//  Created by David Meredith on 11/3/26.
//

import SwiftUI
import SwiftData

struct InventoryTypeForm: View {
    @Bindable var type: InventoryType
    
    var body: some View{
        Form {
            Section("Name") {
                HStack{
                    Text("Name:")
                    TextField("Name", text: $type.name)
                }
            }
        }
    }
}
