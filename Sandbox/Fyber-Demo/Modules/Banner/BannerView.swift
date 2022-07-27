//
//  BannerView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import SwiftUI
import BidOnDecoratorFyber
import BidOn


struct BannerView: View {
    @EnvironmentObject var vm: BannerViewModel
        
    var body: some View {
        AdPresentationView(
            title: "Banner",
            events: vm.events,
            isAdPresented: $vm.isPresented,
            content: { content }
        ) {
            AdBannerView(
                placement: vm.placement
            )
            .background(Color(.secondarySystemBackground))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .transition(.move(edge: .bottom))
            .zIndex(1)
        }
    }
    
    var content: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation {
                        vm.isPresented.toggle()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(vm.state.color)
                            .frame(height: 44)
                        Text(vm.isPresented ? "Hide" : "Present")
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
                Section(header: Text("Placement")) {
                    TextField("Placement", text: $vm.placement)
                        .textFieldStyle(.automatic)
                }
                
                Section(header: Text("Auto refresh")) {
                    Toggle("Enabled", isOn: $vm.isAutorefreshing)
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
                    Toggle("Enabled", isOn: $vm.isAdaptiveSize)
                }
            }
        }
    }
}


struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView()
    }
}
