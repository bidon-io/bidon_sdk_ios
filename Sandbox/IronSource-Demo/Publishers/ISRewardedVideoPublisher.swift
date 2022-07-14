//
//  ISRewardedVideoPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator
import SwiftUI


struct ISRewardedVideoPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
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
    
    func produce(_ event: ISRewardedVideoPublisher.Event) {
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


extension IronSourceDecorator.Proxy {
    var rewardedVideoPublisher: AnyPublisher<AdEventModel, Never> {
        return ISRewardedVideoPublisher { [unowned self] delegate in
            self.setRewardedVideoDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension ISRewardedVideoPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .hasChangedAvailability(let available):
            return Text("ad did change availability. ") + Text(available ? "ad is available" : "ad is not available").bold()
        case .didReceiveReward:
            return Text("ad did receive reward")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didStart:
            return Text("ad did start")
        case .didEnd:
            return Text("ad did end")
        case .didClick:
            return Text("ad did click")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didReceiveReward(let placementInfo):
            text = "Placement info: \(placementInfo?.debugDescription ?? "-")"
        case .didClick(let placementInfo):
            text = "Placement info: \(placementInfo?.debugDescription ?? "-")"
        case .didFailToShowWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "arrow.down")
    }
    
    var accentColor: Color {
        .blue
    }
}
