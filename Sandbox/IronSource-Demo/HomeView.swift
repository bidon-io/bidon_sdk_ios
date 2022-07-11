//
//  HomeView.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import SwiftUI


struct HomeView: View {
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
        }
    }
}
