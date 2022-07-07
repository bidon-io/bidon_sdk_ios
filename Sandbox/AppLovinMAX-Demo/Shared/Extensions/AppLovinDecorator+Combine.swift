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
            AdEventPublishers.BNMAAdDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAuctionDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdReviewDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdRevenueDelegatePublisher(self).eraseToAnyPublisher()
        ]
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
}


extension BNMARewardedAd: BNMARewardedAdDelegateProvider, BNMAAdRevenueDelegateProvider, BNMAAdReviewDelegateProvider, BNMAuctionDelegateProvider {
    var publisher: AnyPublisher<AdEvent, Never> {
        let publishers: [AnyPublisher<AdEvent, Never>] = [
            AdEventPublishers.BNMARewardedAdDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAuctionDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdReviewDelegatePublisher(self).eraseToAnyPublisher(),
            AdEventPublishers.BNMAAdRevenueDelegatePublisher(self).eraseToAnyPublisher()
        ]
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
}
