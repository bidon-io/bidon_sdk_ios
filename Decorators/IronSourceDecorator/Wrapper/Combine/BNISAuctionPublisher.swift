//
//  BNISAuctionPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import MobileAdvertising
import SwiftUI


@available(iOS 13, *)
public struct BNISAuctionPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didStartAuction
        case didStartAuctionRound(round: String, pricefloor: Price)
        case didReceiveAd(ad: Ad)
        case didCompleteAuctionRound(round: String)
        case didCompleteAuction(ad: Ad?)
    }
    
    private let delegate: (BNISAuctionDelegate) -> ()
    
    init(delegate: @escaping (BNISAuctionDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNISAuctionDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class BNISAuctionDelegateSubscription<S>: NSObject, Subscription, BNISAuctionDelegate
where S : Subscriber, S.Input == BNISAuctionPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNISAuctionPublisher.Event) {
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
        produce(.didStartAuction)
    }
    
    func didStartAuctionRound(_ round: String, pricefloor: Price) {
        produce(.didStartAuctionRound(round: round, pricefloor: pricefloor))
    }
    
    func didReceiveAd(_ ad: Ad) {
        produce(.didReceiveAd(ad: ad))
    }
    
    func didCompleteAuctionRound(_ round: String) {
        produce(.didCompleteAuctionRound(round: round))
    }
    
    func didCompleteAuction(_ winner: Ad?) {
        produce(.didCompleteAuction(ad: winner))
    }
}


@available(iOS 13, *)
public extension IronSourceDecorator.BNISProxy {
    var auctionInterstitialPublisher: BNISAuctionPublisher {
        return BNISAuctionPublisher { [unowned self] delegate in
            self.setAuctionInterstitialDelegate(delegate)
        }
    }
    
    var auctionRewardedVideoPublisher: BNISAuctionPublisher {
        return BNISAuctionPublisher { [unowned self] delegate in
            self.setAuctionRewardedVideoDelegate(delegate)
        }
    }
    
    var auctionBannerPublisher: BNISAuctionPublisher {
        return BNISAuctionPublisher { [unowned self] delegate in
            self.setAuctionBannerDelegate(delegate)
        }
    }
}

