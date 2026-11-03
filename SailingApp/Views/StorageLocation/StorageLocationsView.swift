//
//  StorageLocationsView.swift
//  SailingApp
//
//  Created by David Meredith on 10/29/26.
//

import SwiftUI
import SwiftData

struct StorageLocationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    private var locations: [StorageLocation] {
        boatStore.currentBoat!.storageLocations
    }

    @State private var showingAddItem = false
    
    var body: some View {
            List {
                if locations.isEmpty {
                    ContentUnavailableView(
                        "No Storage Locations",
                        systemImage: "archivebox",
                        description: Text("Tap + to add your first storage location.")
                    )
                } else {
                    ForEach(locations) { location in
                        NavigationLink {
                            StorageLocationDetailView(location: location)
                        } label: {
                            Text(location.name)
                                .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        let locationsToDelete = offsets.map { locations[$0] }

                        withAnimation {
                            for location in locationsToDelete {
                                modelContext.delete(location)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Storage Locations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Location", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                NavigationStack {
                    AddStorageLocationView()
                }
            }
        }
    }

    struct StorageLocationDetailView: View {
        @Bindable var location: StorageLocation

        var body: some View {
            StorageLocationForm(location: location)
                .navigationTitle(location.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    #Preview {
        NavigationStack {
            StorageLocationsView()
        }
        .modelContainer(for: [InventoryItem.self, Boat.self, StorageLocation.self], inMemory: true)
        .environment(BoatStore())
    }
