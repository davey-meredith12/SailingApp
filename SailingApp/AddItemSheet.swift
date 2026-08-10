//
//  AddItemSheet.swift
//  SailingApp
//
//  Created by David Meredith on 8/8/26.
//

import SwiftUI


struct AddItemSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let content: Content        // stored View, concrete type inferred by caller
    let onAdd: () -> Void       // stored closure, called later → must be @escaping

    init(title: String, @ViewBuilder content: () -> Content, onAdd: @escaping () -> Void) {
        self.title = title
        self.content = content()   // build the view now
        self.onAdd = onAdd
    }

    var body: some View {
        NavigationStack {
            content
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    onAdd()
                    dismiss()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal)
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label: { Image(systemName: "xmark") }
            }
        }
    }
}
