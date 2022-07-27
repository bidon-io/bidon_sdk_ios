//
//  BNFYBAuctionPublisher.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNFYBAuctionDelegateProvider = (BNFYBAuctionDelegate?) -> ()


@available(iOS 13, *)
public struct BNFYBAuctionPublisher: Publisher {
    public enum Event {
        case didStartAuction(placement: String)
        case didStartAuctionRound(round: String, placement: String, pricefloor: Price)
        case didReceiveAd(ad: Ad, placement: String)
        case didCompleteAuctionRound(round: String, placement: String)
        case didCompleteAuction(ad: Ad?, placement: String)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNFYBAuctionDelegateProvider
    
    init(_ provider: @escaping BNFYBAuctionDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBAuctionDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNFYBAuctionDelegateSubscription<S>: Subscription, BNFYBAuctionDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNFYBAuctionPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNFYBAuctionPublisher.Event) {
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

    func didStartAuction(placement: String) {
        trigger(.didStartAuction(placement: placement))
    }
    
    func didStartAuctionRound(_ round: String, placement: String, pricefloor: Price) {
        trigger(.didStartAuctionRound(round: round, placement: placement, pricefloor: pricefloor))
    }
    
    func didReceiveAd(_ ad: Ad, placement: String) {
        trigger(.didReceiveAd(ad: ad, placement: placement))
    }
    
    func didCompleteAuctionRound(_ round: String, placement: String) {
        trigger(.didCompleteAuctionRound(round: round, placement: placement))
    }
    
    func didCompleteAuction(_ winner: Ad?, placement: String) {
        trigger(.didCompleteAuction(ad: winner, placement: placement))
    }
}


@available(iOS 13, *)
public extension BNFYBInterstitial {
    static var auctionPublisher: BNFYBAuctionPublisher {
        BNFYBAuctionPublisher { delegate in
            self.auctionDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNFYBRewarded {
    static var auctionPublisher: BNFYBAuctionPublisher {
        BNFYBAuctionPublisher { delegate in
            self.auctionDelegate = delegate
        }
    }
}


@available(iOS 13, *)
public extension BNFYBBanner {
    static var auctionPublisher: BNFYBAuctionPublisher {
        BNFYBAuctionPublisher { delegate in
            self.auctionDelegate = delegate
        }
    }
}
