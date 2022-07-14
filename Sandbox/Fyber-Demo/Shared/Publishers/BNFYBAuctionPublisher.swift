//
//  BNFYBAuctionPublisher.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import Combine
import FyberDecorator
import FairBidSDK
import MobileAdvertising


struct BNFYBAuctionPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    private let delegate: (BNFYBAuctionDelegate?) -> ()
    private let adType: AdType
    
    init(
        adType: AdType,
        _ delegate: @escaping (BNFYBAuctionDelegate?) -> ()
    ) {
        self.adType = adType
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBAuctionDelegateSubscription(
            adType: adType,
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNFYBAuctionDelegateSubscription<S>: NSObject, Subscription, BNFYBAuctionDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    let adType: AdType
    
    init(adType: AdType, subscriber: S) {
        self.subscriber = subscriber
        self.adType = adType
        super.init()
    }
    
    func produce(_ event: AdEvent) {
        guard let subscriber = subscriber else { return }
        
        demand -= 1
        demand += subscriber.receive(
            AdEventModel(adType: adType, event: event)
        )
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func didStartAuction(placement: String) {
        produce(.didStartAuction(placement: placement))
    }
    
    func didStartAuctionRound(_ round: String, placement: String, pricefloor: Price) {
        produce(.didStartAuctionRound(placement: placement, id: round, pricefloor: pricefloor))
    }
    
    func didReceiveAd(_ ad: Ad, placement: String) {
        produce(.didReceive(placement: placement, ad: ad))
    }
    
    func didCompleteAuctionRound(_ round: String, placement: String) {
        produce(.didCompleteAuctionRound(placement: placement, id: round))
    }
    
    func didCompleteAuction(_ winner: Ad?, placement: String) {
        produce(.didCompleteAuction(placement: placement, ad: winner))
    }
}


extension BNFYBInterstitial {
    static func auctionPublisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBAuctionPublisher(adType: .interstitial) { delegate in
            self.auctionDelegate = delegate
        }
        .eraseToAnyPublisher()
    }
}


extension BNFYBRewarded {
    static func auctionPublisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBAuctionPublisher(adType: .rewardedVideo) { delegate in
            self.auctionDelegate = delegate
        }
        .eraseToAnyPublisher()
    }
}


extension BNFYBBanner {
    static func auctionPublisher() -> AnyPublisher<AdEventModel, Never> {
        return BNFYBAuctionPublisher(adType: .banner) { delegate in
            self.auctionDelegate = delegate
        }
        .eraseToAnyPublisher()
    }
}
