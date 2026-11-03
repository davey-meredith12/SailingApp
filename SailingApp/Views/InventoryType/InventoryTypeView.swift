//
//  InventoryTypeView.swift
//  SailingApp
//
//  Created by David Meredith on 11/3/26.
//

import SwiftUI
import SwiftData

struct InventoryTypeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    
    private var types: [InventoryType] {
        boatStore.currentBoat!.inventoryTypes
    }

    @State private var showingAddItem = false
    
    var body: some View {
            List {
                if types.isEmpty {
                    ContentUnavailableView(
                        "No Inventory Types",
                        systemImage: "archivebox",
                        description: Text("Tap + to add your first inventory type.")
                    )
                } else {
                    ForEach(types) { type in
                        NavigationLink {
                            InventoryTypeDetailView(type: type)
                        } label: {
                            Text(type.name)
                                .font(.headline)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        let typesToDelete = offsets.map { types[$0] }

                        withAnimation {
                            for type in typesToDelete {
                                modelContext.delete(type)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inventory Types")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Inventory Type", systemImage: "plus")
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

    struct InventoryTypeDetailView: View {
        @Bindable var type: InventoryType

        var body: some View {
            InventoryTypeForm(type: type)
                .navigationTitle(type.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
