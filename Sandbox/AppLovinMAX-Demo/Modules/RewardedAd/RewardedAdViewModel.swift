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


final class RewardedAdViewModel: AdViewModel {
    @Published var placement: String = ""
    
    private var rewardedAd: BNMARewardedAd? {
        didSet {
            guard let rewardedAd = rewardedAd else { return }
            subscribe(rewardedAd.publisher)
        }
    }
    
    func load() {
        let rewardedAd = BNMARewardedAd.shared(
            withAdUnitIdentifier: adUnitIdentifier,
            sdk: applovin
        )
        rewardedAd.resolver = resolver
        self.rewardedAd = rewardedAd
        self.rewardedAd?.loadAd()
    }
    
    func present() {
        guard let rewardedAd = rewardedAd else { return }
        rewardedAd.show()
    }
    
    func presentWithPlacement() {
        guard let rewardedAd = rewardedAd else { return }
        rewardedAd.show(forPlacement: placement)
    }
}
