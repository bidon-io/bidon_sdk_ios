//
//  BNFYBRewardedPublisher.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 18.07.2022.
//

import Foundation
import Combine
import BidOn


typealias BNFYBRewardedDelegateProvider = (BNFYBRewardedDelegate?) -> ()


@available(iOS 13, *)
public struct BNFYBRewardedPublisher: Publisher {
    public enum Event {
        case rewardedWillRequest(placement: String)
        case rewardedIsAvailable(placement: String)
        case rewardedIsUnavailable(placement: String)
        case rewardedDidShow(placement: String, impressionData: Ad)
        case rewardedDidFailToShow(placement: String, error: Error, impressionData: Ad)
        case rewardedDidClick(placement: String)
        case rewardedDidDismiss(placement: String)
        case rewardedDidComplete(placement: String, userRewarded: Bool)
    }
    
    public typealias Output = Event
    public typealias Failure = Never
    
    private let provider: BNFYBRewardedDelegateProvider
    
    init(_ provider: @escaping BNFYBRewardedDelegateProvider) {
        self.provider = provider
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNFYBRewardedDelegateSubscription(
            subscriber: subscriber
        )
        
        provider(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
fileprivate class BNFYBRewardedDelegateSubscription<S>: Subscription, BNFYBRewardedDelegate
where S : Subscriber, S.Failure == Never, S.Input == BNFYBRewardedPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
    }
    
    func trigger(_ event: BNFYBRewardedPublisher.Event) {
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
    
    func rewardedWillRequest(_ placementId: String) {
        trigger(.rewardedWillRequest(placement: placementId))
    }
    
    func rewardedIsAvailable(_ placementId: String) {
        trigger(.rewardedIsAvailable(placement: placementId))
    }
    
    func rewardedIsUnavailable(_ placementId: String) {
        trigger(.rewardedIsUnavailable(placement: placementId))
    }
    
    func rewardedDidShow(_ placementId: String, impressionData: Ad) {
        trigger(.rewardedDidShow(placement: placementId, impressionData: impressionData))
    }
    
    func rewardedDidFail(toShow placementId: String, withError error: Error, impressionData: Ad) {
        trigger(.rewardedDidFailToShow(placement: placementId, error: error, impressionData: impressionData))
    }
    
    func rewardedDidClick(_ placementId: String) {
        trigger(.rewardedDidClick(placement: placementId))
    }
    
    func rewardedDidDismiss(_ placementId: String) {
        trigger(.rewardedDidDismiss(placement: placementId))
    }
    
    func rewardedDidComplete(_ placementName: String, userRewarded: Bool) {
        trigger(.rewardedDidComplete(placement: placementName, userRewarded: userRewarded))
    }
}


@available(iOS 13, *)
public extension BNFYBRewarded {
    static var publisher: BNFYBRewardedPublisher {
        BNFYBRewardedPublisher { delegate in
            self.delegate = delegate
        }
    }
}
