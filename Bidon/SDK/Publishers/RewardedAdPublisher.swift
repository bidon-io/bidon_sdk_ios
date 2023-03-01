//
//  RewardedAdPublisher.swift
//  Bidon
//
//  Created by Bidon Team on 26.08.2022.
//

import Foundation
import Combine


@available(iOS 13, *)
public struct RewardedAdPublisher: Publisher {
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
        case willPresentAd(ad: Ad)
        case didFailToPresentAd(error: Error)
        case didDismissAd(ad: Ad)
        case didRewardUser(reward: Reward)
    }
    
    private var RewardedAd: RewardedAd
    
    init(_ RewardedAd: RewardedAd) {
        self.RewardedAd = RewardedAd
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = RewardedAdDelegateSubscription(
            subscriber: subscriber
        )
        
        RewardedAd.delegate = subscription
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class RewardedAdDelegateSubscription<S>: Subscription, RewardedAdDelegate
where S : Subscriber, S.Failure == Never, S.Input == RewardedAdPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: RewardedAdPublisher.Event) {
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
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, willPresentAd ad: Ad) {
        trigger(.willPresentAd(ad: ad))
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didFailToPresentAd error: Error) {
        trigger(.didFailToPresentAd(error: error))
    }
    
    func fullscreenAd(_ fullscreenAd: FullscreenAdObject, didDismissAd ad: Ad) {
        trigger(.didDismissAd(ad: ad))
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdObject, didRewardUser reward: Reward) {
        trigger(.didRewardUser(reward: reward))
    }
}


@available(iOS 13, *)
public extension RewardedAd {
    var publisher: RewardedAdPublisher {
        return RewardedAdPublisher(self)
    }
}
