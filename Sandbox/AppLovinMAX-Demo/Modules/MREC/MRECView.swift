//
//  MRECView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import SwiftUI
import AppLovinDecorator
import MobileAdvertising


struct MRECView: View {    
    @StateObject var vm = MRECViewModel()
    
    @State private var isBannerPresented: Bool = false
    
    var body: some View {
        AdPresentationView(
            title: "MREC",
            events: vm.events,
            isAdPresented: $isBannerPresented,
            content: { content }
        ) {
            ZStack {
                Color(.secondarySystemBackground)
                    .frame(height: 250)
                AdBannerView(
                    isAutoRefresh: .constant(true),
                    isAdaptive: .constant(true),
                    adUnitIdentifier: vm.adUnitIdentifier,
                    adFormat: vm.adFormat,
                    sdk: applovin,
                    event: vm.send
                )
                .frame(maxWidth: .infinity)
                .frame(width: 300, height: 250)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ad Unit Identifier".uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("", text: $vm.adUnitIdentifier)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 44)
            }
        }
        .padding(.horizontal)
    }
}


struct MRECView_Previews: PreviewProvider {
    static var previews: some View {
        MRECView()
    }
}
