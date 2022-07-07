//
//  InterstitialViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator
import AppLovinSDK
import SwiftUI


final class InterstitialViewModel: AdViewModel {
    private var interstitial: BNMAInterstitialAd? {
        didSet {
            guard let interstitial = interstitial else { return }
            subscribe(interstitial.publisher)
        }
    }
    
    
    func load() {
        let interstital = BNMAInterstitialAd(
            adUnitIdentifier: adUnitIdentifier,
            sdk: applovin
        )
    
        self.interstitial = interstital
        self.interstitial?.loadAd()
    }
    
    func present() {
        guard let interstitial = interstitial else { return }
        interstitial.show()
    }
}
