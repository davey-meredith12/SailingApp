import SwiftUI
import SwiftData




struct ContentView: View {
    
    var body: some View{
        BoatsView()
    }
}
    
#Preview {
    let boatStore = BoatStore()
    
    ContentView()
        .modelContainer(for: [InventoryItem.self, Boat.self], inMemory: true)
        .environment(boatStore)
}
