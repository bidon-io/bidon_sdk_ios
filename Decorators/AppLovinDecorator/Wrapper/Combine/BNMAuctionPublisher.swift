//
//  BNMAuctionPublisher.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import MobileAdvertising


typealias BNMAuctionDelegateProvider = (BNMAuctionDelegate?) -> ()

@available(iOS 13, *)
public struct BNMAuctionPublisher: Publisher {
    public enum Event {
        case didStartAuction
        case didStartAuctionRound(round: String, pricefloor: Price)
        case didReceiveAd(ad: Ad)
        case didCompleteAuctionRound(round: String)
        case didCompleteAuction(ad: Ad?)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNMAuctionDelegateProvider
    
    init(_ provider: @escaping BNMAuctionDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNMAuctionDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNMAuctionDelegateSubscription<S>: Subscription, BNMAuctionDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNMAuctionPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNMAuctionPublisher.Event) {
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

    func didStartAuction() {
        trigger(.didStartAuction)
    }
    
    func didStartAuctionRound(_ round: String, pricefloor: Price) {
        trigger(.didStartAuctionRound(round: round, pricefloor: pricefloor))
    }
    
    func didReceiveAd(_ ad: Ad) {
        trigger(.didReceiveAd(ad: ad))
    }
    
    func didCompleteAuctionRound(_ round: String) {
        trigger(.didCompleteAuctionRound(round: round))
    }
    
    func didCompleteAuction(_ winner: Ad?) {
        trigger(.didCompleteAuction(ad: winner))
    }
}


@available(iOS 13, *)
public extension BNMAInterstitialAd {
    var auctionPublisher: BNMAuctionPublisher {
        BNMAuctionPublisher { [weak self] delegate in
            self?.auctionDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMARewardedAd {
    var auctionPublisher: BNMAuctionPublisher {
        BNMAuctionPublisher { [weak self] delegate in
            self?.auctionDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNMAAdView {
    var auctionPublisher: BNMAuctionPublisher {
        BNMAuctionPublisher { [weak self] delegate in
            self?.auctionDelegate = delegate
        }
    }
}

