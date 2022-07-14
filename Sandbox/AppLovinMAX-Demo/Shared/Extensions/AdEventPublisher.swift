//
//  AdEventPublisher.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator
import MobileAdvertising


protocol BNMAAdDelegateProvider: AnyObject {
    var delegate: BNMAAdDelegate? { get set }
}

protocol BNMARewardedAdDelegateProvider: AnyObject {
    var delegate: BNMARewardedAdDelegate? { get set }
}

protocol BNMAAdRevenueDelegateProvider: AnyObject {
    var revenueDelegate: BNMAAdRevenueDelegate? { get set }
}

protocol BNMAAdReviewDelegateProvider: AnyObject {
    var adReviewDelegate: BNMAAdReviewDelegate? { get set }
}

protocol BNMAuctionDelegateProvider: AnyObject {
    var auctionDelegate: BNMAuctionDelegate? { get set }
}


struct AdEventPublishers {
    typealias Output = AdEvent
    typealias Failure = Never
    
    struct BNMAAdPublisher: Publisher {
        typealias Output = AdEvent
        typealias Failure = Never
        
        private var provider: BNMAAdDelegateProvider
        
        init(_ provider: BNMAAdDelegateProvider) {
            self.provider = provider
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = BNMAAdDelegateSubscription(
                subscriber: subscriber
            )
            
            provider.delegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    struct BNMARewardedAdPublisher: Publisher {
        typealias Output = AdEvent
        typealias Failure = Never
        
        private var provider: BNMARewardedAdDelegateProvider
        
        init(_ provider: BNMARewardedAdDelegateProvider) {
            self.provider = provider
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = BNMAAdDelegateSubscription(
                subscriber: subscriber
            )
            
            provider.delegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    struct BNMAAdRevenuePublisher: Publisher {
        typealias Output = AdEvent
        typealias Failure = Never
        
        private var provider: BNMAAdRevenueDelegateProvider
        
        init(_ provider: BNMAAdRevenueDelegateProvider) {
            self.provider = provider
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = BNMAAdRevenueDelegateSubscription(
                subscriber: subscriber
            )
            
            provider.revenueDelegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    struct BNMAAdReviewPublisher: Publisher {
        typealias Output = AdEvent
        typealias Failure = Never
        
        private var provider: BNMAAdReviewDelegateProvider
        
        init(_ provider: BNMAAdReviewDelegateProvider) {
            self.provider = provider
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = BNMAAdReviewDelegateSubscription(
                subscriber: subscriber
            )
            
            provider.adReviewDelegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
    
    struct BNMAuctionPublisher: Publisher {
        typealias Output = AdEvent
        typealias Failure = Never
        
        private var provider: BNMAuctionDelegateProvider
        
        init(_ provider: BNMAuctionDelegateProvider) {
            self.provider = provider
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = BNMAuctionDelegateSubscription(
                subscriber: subscriber
            )
            
            provider.auctionDelegate = subscription
            
            subscriber.receive(subscription: subscription)
        }
    }
}


extension AdEventPublishers {
    fileprivate class Subscription<S>: NSObject
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        
        var demand: Subscribers.Demand = .none
        
        init(subscriber: S) {
            self.subscriber = subscriber
            super.init()
        }
        
        func trigger(event: AdEvent) {
            guard let subscriber = subscriber else { return }
                        
            demand -= 1
            demand += subscriber.receive(event)
        }
        
        func cancel() {
            demand = .none
            subscriber = nil
        }
    }
    
    final fileprivate class BNMAAdDelegateSubscription<S>: Subscription<S>, BNMARewardedAdDelegate
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        func didLoad(_ ad: Ad) {
            trigger(event: .didLoad(ad: ad))
        }
        
        func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: Error) {
            trigger(event: .didFail(id: adUnitIdentifier, error: error))
        }
        
        func didDisplay(_ ad: Ad) {
            trigger(event: .didDisplay(ad: ad))
        }
        
        func didHide(_ ad: Ad) {
            trigger(event: .didHide(ad: ad))
        }
        
        func didClick(_ ad: Ad) {
            trigger(event: .didClick(ad: ad))
        }
        
        func didFail(toDisplay ad: Ad, withError error: Error) {
            trigger(event: .didDisplayFail(ad: ad, error: error))
        }
        
        func didRewardUser(for ad: Ad, with reward: Reward) {
            trigger(event: .didReward(ad: ad, reward: reward))
        }
    }
    
    final fileprivate class BNMAAdRevenueDelegateSubscription<S>: Subscription<S>, BNMAAdRevenueDelegate
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        func didPayRevenue(for ad: Ad) {
            trigger(event: .didPay(ad: ad))
        }
    }
    
    final fileprivate class BNMAAdReviewDelegateSubscription<S>: Subscription<S>, BNMAAdReviewDelegate
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: Ad) {
            trigger(event: .didGenerateCreativeId(id: creativeIdentifier, ad: ad))
        }
    }

    final fileprivate class BNMAuctionDelegateSubscription<S>: Subscription<S>, BNMAuctionDelegate
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        func didStartAuction() {
            trigger(event: .didStartAuction)
        }
        
        func didStartAuctionRound(_ round: String, pricefloor: Price) {
            trigger(event: .didStartAuctionRound(id: round, pricefloor: pricefloor))
        }
        
        func didReceiveAd(_ ad: Ad) {
            trigger(event: .didReceive(ad: ad))
        }
        
        func didCompleteAuctionRound(_ round: String) {
            trigger(event: .didCompleteAuctionRound(id: round))
        }
        
        func didCompleteAuction(_ winner: Ad?) {
            trigger(event: .didCompleteAuction(ad: winner))
        }
    }
}


extension AdEventPublishers.Subscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
}
