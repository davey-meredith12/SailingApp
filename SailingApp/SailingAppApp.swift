//
//  SailingAppApp.swift
//  SailingApp
//
//  Created by David Meredith on 8/5/26.
//

import SwiftUI
import SwiftData

@main
struct SailingAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            InventoryItem.self,
            Boat.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var boatStore = BoatStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(boatStore)
        }
        .modelContainer(sharedModelContainer)
    }
}

@Observable
class BoatStore {
    var currentBoat: Boat?
}
