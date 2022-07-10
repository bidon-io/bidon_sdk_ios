//
//  InterstitialView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//
import Foundation
import SwiftUI
import AppLovinDecorator
import MobileAdvertising


struct InterstitialView: View {
    @StateObject var vm = InterstitialViewModel()
        
    var body: some View {
        FullscreenAdPresentationView(
            title: "Interstitial",
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
}


struct InterstitialView_Previews: PreviewProvider {
    static var previews: some View {
        InterstitialView()
    }
}
