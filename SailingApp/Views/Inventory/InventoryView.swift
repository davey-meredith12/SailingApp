//
//  InventoryView.swift
//  SailingApp
//
//  Created by David Meredith on 8/6/26.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    @AppStorage("expirationWarningDays") private var expirationWarningDays: Int = 7

    
    private var items: [InventoryItem] {
        (boatStore.currentBoat?.inventory.sorted { $0.name < $1.name })!
    }
    private var groupedItems: [(type: InventoryType, items:[InventoryItem])] {
        let grouped = Dictionary(grouping: items) {item in
            item.type
        }
        return InventoryType.allCases.compactMap { type in
            guard let itemsForType = grouped[type], !itemsForType.isEmpty else {return nil}
            return (type: type, items: itemsForType)
        }
    }

    @State private var showingAddItem = false
    
    var body: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Inventory Items",
                    systemImage: "shippingbox",
                    description: Text("Tap + to add your first inventory item.")
                )
            } else {
                ForEach(groupedItems, id: \.type) { group in
                    Section(group.type.rawValue){
                        ForEach(group.items){ item in
                                HStack{
                                    NavigationLink{
                                        InventoryDetailView(item: item)
                                    } label:{
                                        HStack(alignment: .center){
                                            InventoryItemRowLabel(item: item)
                                            
                                            Spacer()
                                            
                                            if item.isExpired {
                                                WarningTag{
                                                    Text("Expired")
                                                }
                                            }
                                            
                                            if item.isCloseToExpiring(numWarningDays: expirationWarningDays), let days = item.daysUntilExpiration {
                                                WarningTag(color: .orange){
                                                    if days == 0 {
                                                        Text("Expires today")
                                                    } else{
                                                        Text("Expires in \(days) days")
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    InventoryStepperControl(item: item)
                                }
                                .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                
                
                
                
                
            }
        }
        .navigationTitle("Inventory")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            NavigationStack {
                AddInventoryView()
            }
        }
        
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct InventoryItemRowLabel: View{
    
    @Bindable var item: InventoryItem
    
    var body: some View{
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            
            Text(item.type.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !item.location.isEmpty {
                Text(item.location)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

struct InventoryDetailView: View {
    @Bindable var item: InventoryItem

    var body: some View {
        InventoryItemForm(item: item)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InventoryStepperControl: View {
    @Bindable var item: InventoryItem
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 10) {
                
                //Minus button
                Button {
                    if item.amount > 0 { item.amount -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(item.amount > 0 ? .red : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)
                .disabled(item.amount <= 0)
                
                //Amount label
                Text("\(item.amount)")
                    .font(.headline)
                    .monospacedDigit()
                    .frame(minWidth: 24)
                
                //Plus Button
                Button {
                    item.amount += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            .overlay(alignment: .bottom){
                if item.isLow {
                    WarningTag{
                        Text("Low")
                    }
                    .offset(y: 24)
                }
            }
        }
    }
}

struct WarningTag<Content: View>: View {
    let color: Color
    let content: Content
    
    init(color: Color = .red, @ViewBuilder content: () -> Content){
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        content
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    InventoryView()
}
