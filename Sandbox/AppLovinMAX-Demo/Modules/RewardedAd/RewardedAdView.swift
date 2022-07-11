//
//  RewardedAdView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import SwiftUI
import AppLovinDecorator
import MobileAdvertising


struct RewardedAdView: View {
    static private let offset: CGFloat = 154
    
    @StateObject var vm = RewardedAdViewModel()
    
    @State private var offset: CGFloat = RewardedAdView.offset
    
    var body: some View {
        FullscreenAdPresentationView(
            title: "Rewarded Ad",
            events: vm.events
        ) {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Button(action: {
                        vm.state.isReady ? vm.present() : vm.load()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(vm.state.color)
                                .frame(height: 44)
                            Text(vm.state.text)
                                .bold()
                        }
                    }
                    .foregroundColor(.white)
                    .disabled(vm.state.disabled)
                    
                    if vm.state.isAnimating {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    
                    if vm.state.isFailed {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                List {
                    Section(header: Text("Ad Unit Identifier")) {
                        TextField("Ad Unit Identifier", text: $vm.adUnitIdentifier)
                            .textFieldStyle(.automatic)
                    }
                    
                    Section(header: Text("Placement")) {
                        TextField("Placement", text: $vm.placement)
                            .textFieldStyle(.automatic)
                        Button(action: vm.presentWithPlacement) {
                            HStack {
                                Spacer()
                                Text("Show with placement")
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}


struct RewardedAdView_Previews: PreviewProvider {
    static var previews: some View {
        RewardedAdView()
    }
}
