//
//  AdListView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import SwiftUI


struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ads")) {
                    NavigationLink(
                        "Interstitial",
                        destination: InterstitialView()
                    )
                    NavigationLink(
                        "Rewarded Ad",
                        destination: RewardedAdView()
                    )
                    NavigationLink(
                        "Banner",
                        destination: BannerView()
                    )
                    NavigationLink(
                        "MREC",
                        destination: MRECView()
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
