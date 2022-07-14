//
//  BannerView.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import SwiftUI
import IronSource
import MobileAdvertising


struct BannerView: View {
    @StateObject var vm = BannerViewModel()
    
    var body: some View {
        AdPresentationView(
            title: "Banner",
            events: vm.events,
            isAdPresented: $vm.isPresented,
            content: { content }
        ) {
            AdBannerView(size: vm.format.size)
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
                            .fill(Color.blue)
                            .frame(height: 44)
                        Text(vm.isPresented ? "Hide" : "Present")
                            .bold()
                    }
                }
                .foregroundColor(.white)
                
                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            List {
                Section(header: Text("Size")) {
                    ForEach(BannerFormat.allCases, id: \.self) { format in
                        Button(action: {
                            withAnimation {
                                vm.format = format
                            }
                        }) {
                            HStack {
                                Text(format.rawValue)
                                Spacer()
                                if vm.format == format {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
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

