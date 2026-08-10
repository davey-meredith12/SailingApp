//
//  SettingsView.swift
//  SailingApp
//
//  Created by David Meredith on 8/8/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("expirationWarningDays") private var expirationWarningDays: Int = 7
    
    var body: some View {
        Form {
            Section {
                Stepper(value: $expirationWarningDays, in: 1...30) {
                    HStack {
                        Text("Expiration Warning")
                        Spacer()
                        Text("\(expirationWarningDays) days")
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text("Items expiring within this many days will show an \"Expiring Soon\" tag.")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
