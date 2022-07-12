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
                    Button("Show", action: vm.showInterstitial)
                }
                
                Section(header: Text("Rewarded Video")) {
                    Button("Show", action: vm.showRewardedVideo)
                }
            }
            .foregroundColor(.primary)
            .navigationBarHidden(false)
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
    }
    
    var content: some View {
        NavigationView {
            List(vm.events) { event in
                AdEventView(model: event)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Events")
        }
    }
}
