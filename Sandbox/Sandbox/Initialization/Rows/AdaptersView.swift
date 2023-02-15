//
//  AdaptersView.swift
//  Sandbox
//
//  Created by Stas Kochkin on 14.02.2023.
//

import Foundation
import SwiftUI
import BidOn


struct AdaptersView: View {
    @Binding var adapters: [BidOn.Adapter]
    
    var body: some View {
        ForEach($adapters, id: \.identifier) { $adapter in
            Button(action: {
                withAnimation {
                    adapter.isEnabled = true
                }
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("BidOn \(adapter.name) Adapter")
                            .foregroundColor(adapter.isEnabled ? .secondary : .primary)
                        Text("SDK version \(adapter.sdkVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if adapter.isEnabled {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .disabled(adapter.isEnabled)
        }
    }
}


extension BidOn.Adapter {    
    var isEnabled: Bool {
        get { BidOnSdk.registeredAdapters().contains { $0.identifier == self.identifier } }
        set {
            guard newValue else { return }
            BidOnSdk.registerAdapter(adapter: self)
        }
    }
}
