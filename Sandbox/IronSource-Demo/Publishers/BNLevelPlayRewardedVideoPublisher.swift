//
//  BNLevelPlayRewardedVideoPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator
import MobileAdvertising
import SwiftUI


struct BNLevelPlayRewardedVideoPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
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
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayRewardedVideoDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNLevelPlayRewardedVideoDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayRewardedVideoDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayRewardedVideoPublisher.Event) {
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


extension IronSourceDecorator.Proxy {
    var levelPlayRewardedVideoPublisher: AnyPublisher<AdEventModel, Never> {
        return BNLevelPlayRewardedVideoPublisher { [unowned self] delegate in
            self.setLevelPlayRewardedVideoDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension BNLevelPlayRewardedVideoPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .hasAvailableAd:
            text = Text("has available ad")
        case .hasNoAvailableAd:
            text = Text("has no available ad")
        case .didReceiveReward:
            return Text("ad did receive reward")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didClick:
            return Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .hasAvailableAd(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didReceiveReward(let placement, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " placement: " + (placement?.debugDescription ?? "-")
        case .didFailToShowWithError(let error, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " error: " + (error?.localizedDescription ?? "-")
        case .didOpen(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClose(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClick(let placement, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " placement: " + (placement?.debugDescription ?? "-")
        default:
            text = ""
        }
        
        return Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    var image: Image {
        Image(systemName: "gamecontroller")
    }
    
    var accentColor: Color {
        .red
    }
}
