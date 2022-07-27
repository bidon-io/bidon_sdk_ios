//
//  BNFYBInterstitialPublisher.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNFYBInterstitialDelegateProvider = (BNFYBInterstitialDelegate?) -> ()


@available(iOS 13, *)
public struct BNFYBInterstitialPublisher: Publisher {
    public enum Event {
        case interstitialWillRequest(placement: String)
        case interstitialIsAvailable(placement: String)
        case interstitialIsUnavailable(placement: String)
        case interstitialDidShow(placement: String, impressionData: Ad)
        case interstitialDidFailToShow(placement: String, error: Error, impressionData: Ad)
        case interstitialDidClick(placement: String)
        case interstitialDidDismiss(placement: String)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNFYBInterstitialDelegateProvider
    
    init(_ provider: @escaping BNFYBInterstitialDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBInterstitialDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNFYBInterstitialDelegateSubscription<S>: Subscription, BNFYBInterstitialDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNFYBInterstitialPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNFYBInterstitialPublisher.Event) {
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
    
    func interstitialWillRequest(_ placementId: String) {
        trigger(.interstitialWillRequest(placement: placementId))
    }
    
    func interstitialIsAvailable(_ placementId: String) {
        trigger(.interstitialIsAvailable(placement: placementId))
    }
    
    func interstitialIsUnavailable(_ placementId: String) {
        trigger(.interstitialIsUnavailable(placement: placementId))
    }
    
    func interstitialDidShow(_ placementId: String, impressionData: Ad) {
        trigger(.interstitialDidShow(placement: placementId, impressionData: impressionData))
    }
    
    func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: Ad) {
        trigger(.interstitialDidFailToShow(placement: placementId, error: error, impressionData: impressionData))
    }
    
    func interstitialDidClick(_ placementId: String) {
        trigger(.interstitialDidClick(placement: placementId))
    }
    
    func interstitialDidDismiss(_ placementId: String) {
        trigger(.interstitialDidDismiss(placement: placementId))
    }
}


@available(iOS 13, *)
public extension BNFYBInterstitial {
    static var publisher: BNFYBInterstitialPublisher {
        BNFYBInterstitialPublisher { delegate in
            self.delegate = delegate
        }
    }
}
