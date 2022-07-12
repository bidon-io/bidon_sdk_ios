//
//  RewardedView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import SwiftUI
import MobileAdvertising


struct RewardedView: View {
    @EnvironmentObject var vm: RewardedViewModel
        
    var body: some View {
        FullscreenAdPresentationView(
            title: "Rewarded",
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
                .padding(.horizontal)
                
                List {
                    Section(header: Text("Placement")) {
                        TextField("Placement", text: $vm.placement)
                            .textFieldStyle(.automatic)
                    }
                }
            }
        }
    }
}


struct RewardedView_Previews: PreviewProvider {
    static var previews: some View {
        RewardedView()
    }
}
