//
//  BannerPublisher.swift
//  Bidon
//
//  Created by Bidon Team on 02.09.2022.
//

import Foundation
import UIKit
import Combine


@available(iOS 13, *)
public struct BannerPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didLoadAd(ad: Ad)
        case didFailToLoadAd(error: Error)
        case didRecordImpression(ad: Ad)
        case didRecordClick(ad: Ad)
        case didStartAuction
        case didStartAuctionRound(auctionRound: String, pricefloor: Price)
        case didReceiveBid(ad: Ad)
        case didCompleteAuctionRound(auctionRound: String)
        case didCompleteAuction(winner: Ad?)
        case didPayRevenue(ad: Ad)
        case willPresentModalView(ad: Ad)
        case didDismissModalView(ad: Ad)
        case willLeaveApplication(ad: Ad)
    }
    
    private var banner: BannerView
    
    init(_ banner: BannerView) {
        self.banner = banner
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BannerDelegateSubscription(
            subscriber: subscriber
        )
        
        banner.delegate = subscription
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class BannerDelegateSubscription<S>: Subscription, AdViewDelegate
where S : Subscriber, S.Failure == Never, S.Input == BannerPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BannerPublisher.Event) {
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
    
    func adObjectDidStartAuction(_ adObject: AdObject) {
        trigger(.didStartAuction)
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
    
    func adView(_ adView: UIView & AdView, willPresentScreen ad: Ad) {
        trigger(.willPresentModalView(ad: ad))
    }
    
    func adView(_ adView: UIView & AdView, didDismissScreen ad: Ad) {
        trigger(.didDismissModalView(ad: ad))
    }
    
    func adView(_ adView: UIView & AdView, willLeaveApplication ad: Ad) {
        trigger(.willLeaveApplication(ad: ad))
    }
}


@available(iOS 13, *)
public extension BannerView {
    var publisher: BannerPublisher {
        return BannerPublisher(self)
    }
}
