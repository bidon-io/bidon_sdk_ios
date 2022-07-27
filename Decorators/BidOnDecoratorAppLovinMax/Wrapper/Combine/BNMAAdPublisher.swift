//
//  BNMAAdPublisher.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNMAAdDelegateProvider = (BNMAAdDelegate?) -> ()

@available(iOS 13, *)
public struct BNMAAdPublisher: Publisher {
    public enum Event {
        case didLoad(ad: Ad)
        case didFailToLoadAd(adUnitIdentifier: String, error: Error)
        case didDisplay(ad: Ad)
        case didHide(ad: Ad)
        case didClick(ad: Ad)
        case didFailToDisplay(ad: Ad, error: Error)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNMAAdDelegateProvider
    
    init(_ provider: @escaping BNMAAdDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNMAAdDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class BNMAAdDelegateSubscription<S>: Subscription, BNMAAdDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNMAAdPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNMAAdPublisher.Event) {
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
}


@available(iOS 13, *)
public extension BNMAInterstitialAd {
    var publisher: BNMAAdPublisher {
        BNMAAdPublisher { [weak self] delegate in
            self?.delegate = delegate
        }
    }
}
