//
//  BoatView.swift
//  SailingApp
//
//  Created by David Meredith on 8/7/26.
//

import SwiftUI
import SwiftData

struct BoatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore

    @Query(sort: \Boat.name)
    private var boats: [Boat]

    @State private var showingAddItem = false

    var body: some View {
        NavigationStack {
            List {
                if boats.isEmpty {
                    ContentUnavailableView(
                        "No Boats",
                        systemImage: "shippingbox",
                        description: Text("Tap + to add your first boat.")
                    )
                } else {
                    ForEach(boats) { boat in
                        NavigationLink(value: boat) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(boat.name)
                                        .font(.headline)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Boats")
            .navigationDestination(for: Boat.self){ boat in
                PageView()
                    .onAppear { boatStore.currentBoat = boat }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Boat", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                NavigationStack {
                    AddBoatView()
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(boats[index])
            }
        }
    }
}

struct BoatEditView: View {
    @Bindable var boat: Boat

    var body: some View {
        BoatForm(boat: boat)
            .navigationTitle(boat.name)
            .navigationBarTitleDisplayMode(.inline)

    }
}

#Preview {
    BoatsView()
}
