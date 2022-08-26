//
//  RewardedAdSection.swift
//  Sandbox
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import SwiftUI


struct RewardedAdSection: View {
    @StateObject var vm = RewardedAdSectionViewModel()
    
    var body: some View {
        Section(header: Text("Rewarded Ad")) {
            Button(action: vm.load) {
                HStack {
                    Text("Load")
                    Spacer()
                    switch vm.state {
                    case .loading:
                        ProgressView()
                    case .error:
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
            
            Button(action: vm.show) {
                HStack {
                    Text("Show")
                    Spacer()
                    switch vm.state {
                    case .presenting:
                        Image(systemName: "play.circle")
                            .foregroundColor(.blue)
                    case .presentationError:
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
            
            NavigationLink("Events", destination: AdEventsList(events: vm.events))
        }
        .foregroundColor(.primary)
    }
}
