//
//  InterstitialPublisher.swift
//  BidOn
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import Combine


@available(iOS 13, *)
public struct InterstitialPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didLoadAd(ad: Ad)
        case didFailToLoadAd(error: Error)
        case didRecordImpression(ad: Ad)
        case didRecordClick(ad: Ad)
        case didStartAuctionRound(auctionRound: String, pricefloor: Price)
        case didReceiveBid(ad: Ad)
        case didCompleteAuctionRound(auctionRound: String)
        case didCompleteAuction(winner: Ad?)
        case didPayRevenue(ad: Ad)
        case willPresentAd(ad: Ad)
        case didFailToPresentAd(error: Error)
        case didDismissAd(ad: Ad)
    }
    
    private var interstitial: Interstitial
    
    init(_ interstitial: Interstitial) {
        self.interstitial = interstitial
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = InterstitialDelegateSubscription(
            subscriber: subscriber
        )
        
        interstitial.delegate = subscription
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class InterstitialDelegateSubscription<S>: Subscription, FullscreenAdDelegate
where S : Subscriber, S.Failure == Never, S.Input == InterstitialPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: InterstitialPublisher.Event) {
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
    
    func adObject(
        _ adObject: AdObject,
        didLoadAd ad: Ad
    ) {
        trigger(.didLoadAd(ad: ad))
    }
    
    func adObject(
        _ adObject: AdObject,
        didFailToLoadAd error: Error
    ) {
        trigger(.didFailToLoadAd(error: error))
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordImpression ad: Ad
    ) {
        trigger(.didRecordImpression(ad: ad))
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordClick ad: Ad
    ) {
        trigger(.didRecordClick(ad: ad))
    }
    
    func adObject(
        _ adObject: AdObject,
        didStartAuctionRound auctionRound: String,
        pricefloor: Price
    ) {
        trigger(.didStartAuctionRound(auctionRound: auctionRound, pricefloor: pricefloor))
    }
    
    func adObject(
        _ adObject: AdObject,
        didReceiveBid ad: Ad
    ) {
        trigger(.didReceiveBid(ad: ad))
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuctionRound auctionRound: String
    ) {
        trigger(.didCompleteAuctionRound(auctionRound: auctionRound))
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuction winner: Ad?
    ) {
        trigger(.didCompleteAuction(winner: winner))
    }
    
    func adObject(
        _ adObject: AdObject,
        didPayRevenue ad: Ad
    ) {
        trigger(.didPayRevenue(ad: ad))
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, willPresentAd ad: Ad) {
        trigger(.willPresentAd(ad: ad))
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didFailToPresentAd error: Error) {
        trigger(.didFailToPresentAd(error: error))
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didDismissAd ad: Ad) {
        trigger(.didDismissAd(ad: ad))
    }
}


@available(iOS 13, *)
public extension Interstitial {
    var publisher: InterstitialPublisher {
        return InterstitialPublisher(self)
    }
}
