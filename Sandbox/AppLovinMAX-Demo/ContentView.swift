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
            VStack {
                Image(systemName: "brain.head.profile")
                    .padding(32)
                    .imageScale(.large)
                
                ZStack {
                    Text("AppLovin MAX + Bidon")
                        .font(Font.system(size: 16, weight: .heavy, design: .monospaced))
                        .offset(x: 0.5, y: 0.5)
                    Text("AppLovin MAX + Bidon")
                        .foregroundColor(.primary)
                        .font(Font.system(size: 16, weight: .heavy, design: .monospaced))
                }
                
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple, .red],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
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
