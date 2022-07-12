//
//  ISRewardedVideoDelegatePublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator


struct ISRewardedVideoDelegatePublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    private let delegate: (ISRewardedVideoDelegate) -> ()
        
    init(_ delegate: @escaping (ISRewardedVideoDelegate) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ISRewardedVideoDelegateSubscribtion(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class ISRewardedVideoDelegateSubscribtion<S>: NSObject, Subscription, ISRewardedVideoDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: AdEvent) {
        guard let subscriber = subscriber else { return }
                    
        demand -= 1
        demand += subscriber.receive(AdEventModel(adType: .rewardedVideo, event: event))
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func rewardedVideoHasChangedAvailability(_ available: Bool) {
        produce(.didChangeAvailability(isAvailable: available))
    }
    
    func didReceiveReward(forPlacement placementInfo: ISPlacementInfo!) {
        produce(.didReceiveReward(placment: placementInfo))
    }
    
    func rewardedVideoDidFailToShowWithError(_ error: Error!) {
        produce(.didFailToShow(error: error))
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
        produce(.didClick(placment: placementInfo))
    }
}


extension IronSourceDecorator.Proxy {
    var rewardedVideoDelelegatePublisher: AnyPublisher<AdEventModel, Never> {
        return ISRewardedVideoDelegatePublisher { [unowned self] delegate in
            self.setRewardedVideoDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}
