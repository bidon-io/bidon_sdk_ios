//
//  ContentView.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 28.06.2022.
//

import SwiftUI
import Combine
import AppLovinDecorator


struct ContentView: View {
    @EnvironmentObject var app: ApplicationDelegate
    
    var body: some View {
        if app.isInitialized {
            HomeView()
        } else {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}


final class ContentViewModel: ObservableObject {
    private lazy var interstitial: BNMAInterstitialAd = {
        let interstitial = BNMAInterstitialAd(
            adUnitIdentifier: "YOUR_AD_UNIT_ID",
            sdk: applovin
        )
        return interstitial
    }()
    
    func appear() {
        interstitial.loadAd()
    }
    
    func present() {
        interstitial.show()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
