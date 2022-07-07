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
                Section("Ads") {
                    NavigationLink(
                        "Interstitial",
                        destination: InterstitialView()
                    )
                }
            }
        }
    }
}


//final class HomeView: ObservableObject {
//    private lazy var interstitial: BNMAInterstitialAd = {
//        let interstitial = BNMAInterstitialAd(
//            adUnitIdentifier: "YOUR_AD_UNIT_ID",
//            sdk: applovin
//        )
//        return interstitial
//    }()
//
//    func appear() {
//        interstitial.loadAd()
//    }
//
//    func present() {
//        interstitial.show()
//    }
//}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
