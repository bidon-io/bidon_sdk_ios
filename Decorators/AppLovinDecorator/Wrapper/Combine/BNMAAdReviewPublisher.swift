//
//  BNMAAdReviewPublisher.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import MobileAdvertising


typealias BNMAAdReviewDelegateProvider = (BNMAAdReviewDelegate?) -> ()

@available(iOS 13, *)
public struct BNMAAdReviewPublisher: Publisher {
    public enum Event {
        case didGenerateCreativeIdentifier(creativeIdentifier: String, ad: Ad)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNMAAdReviewDelegateProvider
    
    init(_ provider: @escaping BNMAAdReviewDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNMAAdReviewDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNMAAdReviewDelegateSubscription<S>: Subscription, BNMAAdReviewDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNMAAdReviewPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNMAAdReviewPublisher.Event) {
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

    func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: Ad) {
        trigger(.didGenerateCreativeIdentifier(creativeIdentifier: creativeIdentifier, ad: ad))
    }
}



@available(iOS 13, *)
public extension BNMAInterstitialAd {
    var adReviewPublisher: BNMAAdReviewPublisher {
        BNMAAdReviewPublisher { [weak self] delegate in
            self?.adReviewDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMARewardedAd {
    var adReviewPublisher: BNMAAdReviewPublisher {
        BNMAAdReviewPublisher { [weak self] delegate in
            self?.adReviewDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMAAdView {
    var adReviewPublisher: BNMAAdReviewPublisher {
        BNMAAdReviewPublisher { [weak self] delegate in
            self?.adReviewDelegate = delegate
        }
    }
}
