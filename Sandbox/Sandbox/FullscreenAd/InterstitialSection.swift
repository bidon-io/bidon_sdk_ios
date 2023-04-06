//
//  InterstitialSection.swift
//  Sandbox
//
//  Created by Bidon Team on 26.08.2022.
//

import Foundation
import SwiftUI


struct InterstitialSection: View {
    @StateObject var vm = FullscreenAdSectionViewModel(adType: .interstitial)
    
    var body: some View {
        Section(header: Text("Interstitial")) {
            Stepper(
                "Pricefloor: \(vm.pricefloor.pretty)",
                value: $vm.pricefloor,
                in: (0.0...100.0),
                step: 0.1
            )
        
            Button(action: load) {
                HStack {
                    Text("Load")
                    Spacer()
                    switch vm.state {
                    case .loading:
                        ProgressView()
                    case .ready:
                        Image(systemName: "circle.fill")
                            .foregroundColor(.green)
                    case .error:
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
            .disabled(vm.state == .loading || vm.state == .ready)
            .adContextMenu(vm.ad, onLoss: vm.notify(loss:))
            
            Button(action: show) {
                HStack {
                    Text("Show")
                    Spacer()
                    switch vm.state {
                    case .presenting:
                        Image(systemName: "play.circle")
                            .foregroundColor(.accentColor)
                    case .presentationError:
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
            
            NavigationLink(
                "Events",
                destination: AdEventsList(events: vm.events)
            )
        }
        .foregroundColor(.primary)
    }
    
    private func load() {
        Task {
            await vm.load()
        }
    }
    
    private func show() {
        Task {
            await vm.show()
        }
    }
}
