//
//  InventoryView.swift
//  SailingApp
//
//  Created by David Meredith on 8/6/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum GroupOption: String, CaseIterable, Identifiable {
    case type = "Type", location = "Location"
    var id: String { rawValue }
}

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name", lowestStock = "Lowest stock", soonestExpiring = "Soonest expiring"
    var id: String { rawValue }
}

enum FilterOption: String, CaseIterable, Identifiable {
    case all = "All", low = "Low", expiring = "Expiring", expired = "Expired"
    var id: String { rawValue }
}

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(BoatStore.self) private var boatStore
    @AppStorage("expirationWarningDays") private var expirationWarningDays: Int = 7
    
    // Menu options grouping
    @AppStorage("inventoryGroup") private var groupOption: GroupOption = .type
    @AppStorage("inventorySort") private var sortOption: SortOption = .name
    @State private var filterOption: FilterOption = .all

    
    @State private var searchText = ""
    
    private var items: [InventoryItem] {
        guard let boat = boatStore.currentBoat else { return [] }

        var result = boat.inventory

        switch filterOption {
        case .all: break
        case .low: result = result.filter { $0.isLow }
        case .expiring: result = result.filter { $0.isCloseToExpiring(numWarningDays: expirationWarningDays) }
        case .expired: result = result.filter { $0.isExpired }
        }

        if !searchText.isEmpty {
            result = result.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                (item.location?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (item.type?.name ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .name:
            return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .lowestStock:
            return result.sorted { ($0.amount - $0.minimumAmount) < ($1.amount - $1.minimumAmount) }
        case .soonestExpiring:
            return result.sorted {
                ($0.daysUntilExpiration ?? .max) < ($1.daysUntilExpiration ?? .max)
            }
        }
    }

    private var groupedItems: [(title: String, items: [InventoryItem])] {
        let grouped = Dictionary(grouping: items) { item -> String in
            switch groupOption {
            case .type: return item.type?.name ?? "Uncategorized"
            case .location: return item.location?.name ?? "No Location"
            }
        }
        return grouped
            .map { (title: $0.key, items: $0.value) }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    @State private var showingAddItem = false
    @State private var showingImporter = false
    @State private var showingExporter = false
    
    var body: some View {
        List {
            if items.isEmpty && searchText == "" {
                ContentUnavailableView(
                    "No Inventory Items",
                    systemImage: "shippingbox",
                    description: Text("Tap + to add your first inventory item.")
                )
            } else if items.isEmpty && searchText != ""{
                ContentUnavailableView(
                    "No Results",
                    systemImage: "shippingbox",
                    description: Text("No results match \"\(searchText)\"")
                )
            } else {
                ForEach(groupedItems, id: \.title) { group in
                    Section(group.title){
                        ForEach(group.items){ item in
                                HStack{
                                    NavigationLink{
                                        InventoryDetailView(item: item)
                                    } label:{
                                        HStack(alignment: .center){
                                            //Label
                                            InventoryItemRowLabel(item: item)
                                            
                                            Spacer()
                                            
                                            //Tags
                                            RowLabelExpirationTags(item: item, expirationWarningDays: expirationWarningDays)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    InventoryStepperControl(item: item)
                                }
                                .padding(.vertical, 4)
                        }
                        .onDelete{offsets in
                            let itemsToDelete = offsets.map { group.items[$0] }
                            
                            withAnimation {
                                for item in itemsToDelete {
                                    modelContext.delete(item)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search inventory")
        .navigationTitle("Inventory")
        .toolbar {
            //Add item button
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
            //menu toolbar
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    //Grouping options
                    Picker("Group by", selection: $groupOption) {
                        ForEach(GroupOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)

                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)

                    Picker("Show", selection: $filterOption) {
                        ForEach(FilterOption.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)

                    Divider()
                    
                    // Import
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Items", systemImage: "square.and.arrow.down")
                    }
                    
                    Button{
                        showingExporter = true
                    } label: {
                        Label("Export Items",
                            systemImage:
                            "square.and.arrow.up")
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            NavigationStack {
                AddInventoryView()
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                importInventory(from: url, boat: boatStore.currentBoat!, context: modelContext)
            case .failure(let error):
                print("File picker error: \(error.localizedDescription)")
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: InventoryCSVDocument(
                text: boatStore.currentBoat.map { inventoryCSV(for: $0) } ?? ""
            ),
            contentType: .commaSeparatedText,
            defaultFilename: "Inventory"
        ) { result in
            if case .failure(let error) = result {
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }
}

/// Displays item information for the row
/// - Parameters:
///     - item: The InventoryItem information to display.
struct InventoryItemRowLabel: View{
    @Bindable var item: InventoryItem
    
    var body: some View{
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)
            
            Text(item.type?.name ?? "Uncategorized")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if item.location != nil {
                Text(item.location!.name)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

/// Displays expiring and expired tags for the row label
/// - Parameters:
///     - item: The InventoryItem.
///     - expirationWarningDays: The number of days away an expiration is for a warning to start showing.
struct RowLabelExpirationTags: View{
    
    @Bindable var item: InventoryItem
    var expirationWarningDays: Int
    
    var body: some View {
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

struct InventoryDetailView: View {
    @Bindable var item: InventoryItem

    var body: some View {
        InventoryItemForm(item: item)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A stepper for controlling the inventory amount of an item
/// - Parameters:
///     - item: The InventoryItem that the stepper should edit.
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

/// Creates a warning tag
/// - Parameters:
///     - color: The color the tag should be
///     - content: The content for the tag, designed around using Text()
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
