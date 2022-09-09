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
                ForEach(AdViewFormat.allCases, id: \.self) { format in
                    Button(action: {
                        withAnimation {
                            vm.format = format
                        }
                    }) {
                        HStack {
                            Text(format.description)
                            Spacer()
                            if vm.format == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
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
        }
        .foregroundColor(.primary)
    }
}


extension AdViewFormat: CaseIterable {
    public static var allCases: [AdViewFormat] = [.adaptive, .banner, .leaderboard, .mrec]
}


extension AdViewFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .adaptive:     return "Adaptive"
        case .banner:       return "Banner"
        case .leaderboard:  return "Leaderboard"
        case .mrec:         return "MREC"
        }
    }
}
