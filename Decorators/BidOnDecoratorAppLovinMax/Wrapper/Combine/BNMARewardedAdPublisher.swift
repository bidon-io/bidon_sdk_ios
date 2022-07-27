//
//  BNMARewardedAdPublisher.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNMARewardedAdDelegateProvider = (BNMARewardedAdDelegate?) -> ()

@available(iOS 13, *)
public struct BNMARewardedAdPublisher: Publisher {
    public enum Event {
        case didLoad(ad: Ad)
        case didFailToLoadAd(adUnitIdentifier: String, error: Error)
        case didDisplay(ad: Ad)
        case didHide(ad: Ad)
        case didClick(ad: Ad)
        case didFailToDisplay(ad: Ad, error: Error)
        case didRewardUser(ad: Ad, reward: Reward)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNMARewardedAdDelegateProvider
    
    init(_ provider: @escaping BNMARewardedAdDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNMARewardedAdDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNMARewardedAdDelegateSubscription<S>: Subscription, BNMARewardedAdDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNMARewardedAdPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNMARewardedAdPublisher.Event) {
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

    func didLoad(_ ad: Ad) {
        trigger(.didLoad(ad: ad))
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: Error) {
        trigger(.didFailToLoadAd(adUnitIdentifier: adUnitIdentifier, error: error))
    }
    
    func didDisplay(_ ad: Ad) {
        trigger(.didDisplay(ad: ad))
    }
    
    func didHide(_ ad: Ad) {
        trigger(.didHide(ad: ad))
    }
    
    func didClick(_ ad: Ad) {
        trigger(.didClick(ad: ad))
    }
    
    func didFail(toDisplay ad: Ad, withError error: Error) {
        trigger(.didFailToDisplay(ad: ad, error: error))
    }
    
    func didRewardUser(for ad: Ad, with reward: Reward) {
        trigger(.didRewardUser(ad: ad, reward: reward))
    }
}


@available(iOS 13, *)
public extension BNMARewardedAd {
    var publisher: BNMARewardedAdPublisher {
        BNMARewardedAdPublisher { [weak self] delegate in
            self?.delegate = delegate
        }
    }
}
