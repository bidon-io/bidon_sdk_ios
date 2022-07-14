//
//  AppLovinDecorator+Combine.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator


extension BNMAInterstitialAd: BNMAAdDelegateProvider, BNMAAdRevenueDelegateProvider, BNMAAdReviewDelegateProvider, BNMAuctionDelegateProvider {
    var publisher: AnyPublisher<AdEvent, Never> {
        let publishers: [AnyPublisher<AdEvent, Never>] = [
            AdEventPublishers.BNMAAdPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAuctionPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdReviewPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdRevenuePublisher(self).eraseToAnyPublisher()
        ]
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
}


extension BNMARewardedAd: BNMARewardedAdDelegateProvider, BNMAAdRevenueDelegateProvider, BNMAAdReviewDelegateProvider, BNMAuctionDelegateProvider {
    var publisher: AnyPublisher<AdEvent, Never> {
        let publishers: [AnyPublisher<AdEvent, Never>] = [
            AdEventPublishers.BNMARewardedAdPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAuctionPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdReviewPublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdRevenuePublisher(self).eraseToAnyPublisher()
        ]
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
}
