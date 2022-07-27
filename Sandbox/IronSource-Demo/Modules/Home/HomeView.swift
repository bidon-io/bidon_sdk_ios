//
//  HomeView.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @State var isLogsPresented: Bool = false
    
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Interstitial")) {
                    LoadButton(state: vm.interstitialState, action: vm.loadInterstitial)
                    Button("Show", action: vm.showInterstitial)
                }
                
                Section(header: Text("Rewarded Video")) {
                    LoadButton(state: vm.rewardedVideoState, action: vm.loadRewardedVideo)
                    Button("Show", action: vm.showRewardedVideo)
                }
                
                Section(header: Text("Banner")) {
                    NavigationLink("Banner", destination: BannerView())
                }
                
                Section(header: Text("Resolution")) {
                    ForEach(Resolution.allCases, id: \.self) { resolution in
                        Button(action: {
                            withAnimation {
                                vm.resolution = resolution
                            }
                        }) {
                            HStack {
                                Text(resolution.rawValue)
                                Spacer()
                                if vm.resolution == resolution {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .foregroundColor(.primary)
            .navigationBarHidden(false)
            .navigationTitle("IronSource + BidOn")
            .sheet(isPresented: $isLogsPresented) { content }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        withAnimation {
                            isLogsPresented.toggle()
                        }
                    }) {
                        Image(systemName: "book")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    var content: some View {
        NavigationView {
            List(vm.events) { event in
                AdEventView(model: event)
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private struct LoadButton: View {
        var state: AdState
        let action: () -> ()
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text("Load")
                    Spacer()
                    switch state {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(.circular)
                    case .failed:
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

