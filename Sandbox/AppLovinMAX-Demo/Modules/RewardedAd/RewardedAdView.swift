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
        ZStack(alignment: .bottom) {
            List(vm.events) { event in
                AdEventView(model: event)
            }
            .listStyle(.plain)
            .padding(.bottom, 100)
            
            VStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary)
                    .frame(width: 32, height: 4)
                    .padding(.top)
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
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ad Unit Identifier".uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("", text: $vm.adUnitIdentifier)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                }
                .padding()
                .padding(.bottom, 64)
            }
            .background(
                RoundedCorners(tl: 20, tr: 20)
            )
            .frame(maxWidth: .infinity)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        withAnimation(.interactiveSpring())  {
                            offset = max(0, min(gesture.translation.height, RewardedAdView.offset))
                        }
                    }
                    .onEnded { _ in
                        if offset > 50 {
                            withAnimation { offset = RewardedAdView.offset }
                        } else {
                            withAnimation { offset = 0 }
                        }
                    }
            )
        }
        .navigationTitle("Rewarded Ad")
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct RewardedAdView_Previews: PreviewProvider {
    static var previews: some View {
        RewardedAdView()
    }
}
