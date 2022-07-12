//
//  AdListView.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import SwiftUI


struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ads")) {
                    NavigationLink(
                        "Interstitial",
                        destination: InterstitialView()
                            .environmentObject(vm.interstitial)
                    )
                    NavigationLink(
                        "Rewarded",
                        destination: RewardedView()
                            .environmentObject(vm.rewarded)
                    )
                    NavigationLink(
                        "Banner",
                        destination: BannerView()
                            .environmentObject(vm.banner)
                    )
                }
            }
            .navigationTitle("Fyber + Bidon")
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
