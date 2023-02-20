//
//  BannerSection.swift
//  Sandbox
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import SwiftUI
import BidOn


struct BannerAdSection: View {
    @EnvironmentObject var vm: BannerAdSectionViewModel
    
    var body: some View {
        Group {
            Section(header: Text("Banner")) {
                Stepper(
                    "Pricefloor: \(vm.pricefloor.pretty)",
                    value: $vm.pricefloor,
                    in: (0.0...100.0),
                    step: 0.1
                )
                
                Button(action: {
                    withAnimation {
                        vm.isPresented.toggle()
                    }
                }) {
                    HStack {
                        Text(vm.isPresented ? "Hide": "Present")
                        Spacer()
                    }
                }
                
                NavigationLink("Events", destination: AdEventsList(events: vm.events))
            }
            
            Section(header: Text("Banner Format")) {
                ForEach(AdBannerWrapperFormat.allCases, id: \.rawValue) { format in
                    Button(action: {
                        withAnimation {
                            vm.format = format
                        }
                    }) {
                        HStack {
                            Text(format.rawValue.capitalized)
                            Spacer()
                            if vm.format == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Banner Settings")) {
                Toggle("Autorefreshing", isOn: $vm.isAutorefreshing)
                HStack {
                    Text("Refresh interval")
                    Spacer()
                    Text(String(format: "%1.0f", vm.autorefreshInterval) + "s")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("5s")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Slider(
                        value: Binding(
                            get: { vm.autorefreshInterval / 5 },
                            set: { vm.autorefreshInterval = 5 * $0 }
                        ),
                        in: (1...6)
                    )
                    
                    Text("30s")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .disabled(true)
        }
        .foregroundColor(.primary)
    }
}


extension BannerFormat: CaseIterable {
    public static var allCases: [BannerFormat] = [.adaptive, .banner, .leaderboard, .mrec]
}

