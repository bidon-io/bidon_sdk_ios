//
//  BannerView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import SwiftUI
import AppLovinDecorator
import MobileAdvertising


struct BannerView: View {    
    @StateObject var vm = BannerViewModel()
    
    @State private var isBannerPresented: Bool = false
    
    var body: some View {
        AdPresentationView(
            title: "Banner",
            events: vm.events,
            isAdPresented: $isBannerPresented,
            content: { content }
        ) {
            AdBannerView(
                isAutoRefresh: $vm.isAutorefresh,
                autorefreshInterval: $vm.autorefreshInterval,
                isAdaptive: $vm.isAdaptive,
                adUnitIdentifier: vm.adUnitIdentifier,
                adFormat: vm.adFormat,
                sdk: applovin,
                event: vm.send
            )
            .background(Color(.secondarySystemBackground))
            .frame(maxWidth: .infinity)
            .frame(height: vm.bannerHieght)
            .transition(.move(edge: .bottom))
            .zIndex(1)
        }
    }
    
    var content: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation {
                        isBannerPresented.toggle()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(vm.state.color)
                            .frame(height: 44)
                        Text(isBannerPresented ? "Hide" : "Present")
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
                Group {
                    Section(header: Text("Ad Unit Identifier")) {
                        TextField("Ad Unit Identifier", text: $vm.adUnitIdentifier)
                            .textFieldStyle(.automatic)
                    }
                    
                    Section(header: Text("Auto refresh")) {
                        Toggle("Enabled", isOn: $vm.isAutorefresh)
                        HStack {
                            Text("Interval")
                            Spacer()
                            Text(String(format: "%1.0f", vm.autorefreshInterval) + "s")
                                .foregroundColor(.secondary)
                        }
                        Slider(
                            value: Binding(
                                get: { vm.autorefreshInterval / 5 },
                                set: { vm.autorefreshInterval = 5 * $0 }
                            ),
                            in: (1...6)
                        )
                    }
                    
                    Section(header: Text("Adaptive size")) {
                        Toggle("Enabled", isOn: $vm.isAdaptive)
                    }
                }
            }
        }
    }
}


struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView()
            .preferredColorScheme(.dark)
    }
}
