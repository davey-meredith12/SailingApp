//
//  PageView.swift
//  SailingApp
//
//  Created by David Meredith on 8/7/26.
//

import SwiftUI
import SwiftData

struct Page : Identifiable{
    let id = UUID()
    let name: String
    let imageName: String
    let destination: PageDestination
}

enum PageDestination{
    case inventory
    case settings
    case boatInfo
}

struct PageView: View {
    @Environment(BoatStore.self) private var boatStore
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible())
    ]
    
    let pages: [Page] = [
        Page(name: "Boat Information",
             imageName: "sailboat",
             destination: PageDestination.boatInfo
            ),
        
        Page(name: "Inventory",
             imageName: "list.bullet.clipboard",
             destination: PageDestination.inventory),
        
        Page(name: "Settings",
             imageName: "gear",
             destination: PageDestination.settings)
    ]
    
    var body: some View {
            ZStack{
                ScrollView{
                    LazyVGrid(columns: columns){
                        ForEach(pages){page in
                            NavigationLink{
                                destinationView(for: page)
                            } label: {
                                PageButton(page: page)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
                .navigationTitle(boatStore.currentBoat?.name ?? "Boat_Name")
                .navigationBarTitleDisplayMode(.large)
            }
    }
    
    @ViewBuilder
    private func destinationView(for page: Page) -> some View {
        switch page.destination {
        case .inventory:
            InventoryView()

        case .settings:
            SettingsView()
            
        case .boatInfo:
            if boatStore.currentBoat != nil {
                BoatEditView(boat: boatStore.currentBoat!)
            }
        }
    }
}

struct PageButton: View {
    let page: Page

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: page.imageName)
                .font(.system(size: 35))

            Text(page.name)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}



#Preview {
    PageView()
}
