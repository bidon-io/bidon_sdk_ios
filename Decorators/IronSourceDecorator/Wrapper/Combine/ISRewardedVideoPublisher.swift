//
//  ISRewardedVideoPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import Combine
import IronSource
import SwiftUI


@available(iOS 13, *)
public struct ISRewardedVideoPublisher: Publisher {
    public typealias Output = Event
    public typealias Failure = Never
    
    public enum Event {
        case hasChangedAvailability(available: Bool)
        case didReceiveReward(placementInfo: ISPlacementInfo!)
        case didFailToShowWithError(error: Error!)
        case didOpen
        case didClose
        case didStart
        case didEnd
        case didClick(placementInfo: ISPlacementInfo!)
    }
    
    private let delegate: (ISRewardedVideoDelegate) -> ()
        
    init(_ delegate: @escaping (ISRewardedVideoDelegate) -> ()) {
        self.delegate = delegate
    }
    
    public func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ISRewardedVideoDelegateSubscribtion(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


@available(iOS 13, *)
final fileprivate class ISRewardedVideoDelegateSubscribtion<S>: NSObject, Subscription, ISRewardedVideoDelegate
where S : Subscriber, S.Input == ISRewardedVideoPublisher.Event {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: ISRewardedVideoPublisher.Event) {
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
    
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        produce(.hasChangedAvailability(available: available))
    }
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        produce(.didReceiveReward(placementInfo: placementInfo))
    }
    
    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        produce(.didFailToShowWithError(error: error))
    }
    
    func rewardedVideoDidOpen() {
        produce(.didOpen)
    }
    
    func rewardedVideoDidClose() {
        produce(.didClose)
    }
    
    func rewardedVideoDidStart() {
        produce(.didStart)
    }
    
    func rewardedVideoDidEnd() {
        produce(.didEnd)
    }
    
    func didClickRewardedVideo(_ placementInfo: ISPlacementInfo!) {
        produce(.didClick(placementInfo: placementInfo))
    }
}


@available(iOS 13, *)
public extension IronSourceDecorator.Proxy {
    var rewardedVideoPublisher: ISRewardedVideoPublisher {
        return ISRewardedVideoPublisher { [unowned self] delegate in
            self.setRewardedVideoDelegate(delegate)
        }
    }
}
