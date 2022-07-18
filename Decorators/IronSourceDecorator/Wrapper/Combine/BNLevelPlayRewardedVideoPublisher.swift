//
//  BNLevelPlayRewardedVideoPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import MobileAdvertising


@available(iOS 13, *)
public struct BNLevelPlayRewardedVideoPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case didReceiveReward(placementInfo: ISPlacementInfo!, adInfo: Ad!)
        case didFailToShowWithError(error: Error!, adInfo: Ad!)
        case didOpen(adInfo: Ad!)
        case didClose(adInfo: Ad!)
        case hasAvailableAd(adInfo: Ad!)
        case hasNoAvailableAd
        case didClick(placementInfo: ISPlacementInfo!, adInfo: Ad!)
    }
    
    private let delegate: (BNLevelPlayRewardedVideoDelegate) -> ()
    
    init(_ delegate: @escaping (BNLevelPlayRewardedVideoDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayRewardedVideoDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class BNLevelPlayRewardedVideoDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayRewardedVideoDelegate
where S : Subscriber, S.Input == BNLevelPlayRewardedVideoPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayRewardedVideoPublisher.Event) {
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
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!, with adInfo: Ad!) {
        produce(.didReceiveReward(placementInfo: placementInfo, adInfo: adInfo))
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: Ad!) {
        produce(.didFailToShowWithError(error: error, adInfo: adInfo))
    }
    
    func didOpen(with adInfo: Ad!) {
        produce(.didOpen(adInfo: adInfo))
    }
    
    func didClose(with adInfo: Ad!) {
        produce(.didClose(adInfo: adInfo))
    }
    
    func hasAvailableAd(with adInfo: Ad!) {
        produce(.hasAvailableAd(adInfo: adInfo))
    }
    
    func hasNoAvailableAd() {
        produce(.hasNoAvailableAd)
    }
    
    func didClick(_ placementInfo: ISPlacementInfo!, with adInfo: Ad!) {
        produce(.hasAvailableAd(adInfo: adInfo))
    }
}

@available(iOS 13, *)
public extension IronSourceDecorator.Proxy {
    var levelPlayRewardedVideoPublisher: BNLevelPlayRewardedVideoPublisher {
        return BNLevelPlayRewardedVideoPublisher { [unowned self] delegate in
            self.setLevelPlayRewardedVideoDelegate(delegate)
        }
    }
}
