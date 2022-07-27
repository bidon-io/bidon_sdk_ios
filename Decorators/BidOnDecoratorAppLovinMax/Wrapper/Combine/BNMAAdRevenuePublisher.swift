//
//  BNMAAdRevenuePublisher.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNMAAdRevenueDelegateProvider = (BNMAAdRevenueDelegate?) -> ()

@available(iOS 13, *)
public struct BNMAAdRevenuePublisher: Publisher {
    public enum Event {
        case didPayRevenue(ad: Ad)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNMAAdRevenueDelegateProvider
    
    init(_ provider: @escaping BNMAAdRevenueDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNMAAdRevenueDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNMAAdRevenueDelegateSubscription<S>: Subscription, BNMAAdRevenueDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNMAAdRevenuePublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNMAAdRevenuePublisher.Event) {
        guard let subscriber = subscriber else { return }
                    
        demand -= 1
        demand += subscriber.receive(event)
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }

    func didPayRevenue(for ad: Ad) {
        trigger(.didPayRevenue(ad: ad))
    }
}


@available(iOS 13, *)
public extension BNMAInterstitialAd {
    var revenuePublisher: BNMAAdRevenuePublisher {
        BNMAAdRevenuePublisher { [weak self] delegate in
            self?.revenueDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMARewardedAd {
    var revenuePublisher: BNMAAdRevenuePublisher {
        BNMAAdRevenuePublisher { [weak self] delegate in
            self?.revenueDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMAAdView {
    var revenuePublisher: BNMAAdRevenuePublisher {
        BNMAAdRevenuePublisher { [weak self] delegate in
            self?.revenueDelegate = delegate
        }
    }
}
