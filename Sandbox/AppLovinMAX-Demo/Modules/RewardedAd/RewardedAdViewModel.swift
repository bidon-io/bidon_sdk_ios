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
            let publisher: AnyPublisher<AdEventModel, Never> = Publishers.MergeMany([
                rewardedAd
                    .publisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                rewardedAd
                    .auctionPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                rewardedAd
                    .adReviewPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                rewardedAd
                    .revenuePublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher()
            ]).eraseToAnyPublisher()
            
            subscribe(publisher)
        }
    }
    
    func load() {
        let rewardedAd = BNMARewardedAd.shared(
            withAdUnitIdentifier: adUnitIdentifier,
            sdk: applovin
        )
        rewardedAd.resolver = resolver
        self.rewardedAd = rewardedAd
        self.rewardedAd?.load()
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
