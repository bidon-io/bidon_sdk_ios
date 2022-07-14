//
//  BNLevelPlayInterstitialPublishers.swift
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


struct BNLevelPlayInterstitialPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
        case didLoad(adInfo: Ad!)
        case didFailToLoadWithError(error: Error!)
        case didFailToShowWithError(error: Error!, adInfo: Ad!)
        case didShow(adInfo: Ad!)
        case didOpen(adInfo: Ad!)
        case didClick(adInfo: Ad!)
        case didClose(adInfo: Ad!)
    }
    
    private let delegate: (BNLevelPlayInterstitialDelegate) -> ()
    
    init(_ delegate: @escaping (BNLevelPlayInterstitialDelegate) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = BNLevelPlayInterstitialDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class BNLevelPlayInterstitialDelegateSubscription<S>: NSObject, Subscription, BNLevelPlayInterstitialDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: BNLevelPlayInterstitialPublisher.Event) {
        guard let subscriber = subscriber else { return }
        
        demand -= 1
        demand += subscriber.receive(AdEventModel(adType: .interstitial, event: event))
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func didLoad(with adInfo: Ad!) {
        produce(.didLoad(adInfo: adInfo))
    }
    
    func didFailToLoadWithError(_ error: Error!) {
        produce(.didFailToLoadWithError(error: error))
    }
    
    func didShow(with adInfo: Ad!) {
        produce(.didShow(adInfo: adInfo))
    }
    
    func didOpen(with adInfo: Ad!) {
        produce(.didOpen(adInfo: adInfo))
    }
    
    func didClick(with adInfo: Ad!) {
        produce(.didClick(adInfo: adInfo))
    }
    
    func didFailToShowWithError(_ error: Error!, andAdInfo adInfo: Ad!) {
        produce(.didFailToShowWithError(error: error, adInfo: adInfo))
    }
    
    func didClose(with adInfo: Ad!) {
        produce(.didClose(adInfo: adInfo))
    }
}


extension IronSourceDecorator.Proxy {
    var levelPlayInterstitialPublisher: AnyPublisher<AdEventModel, Never> {
        return BNLevelPlayInterstitialPublisher { [unowned self] delegate in
            self.setLevelPlayInterstitialDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension BNLevelPlayInterstitialPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        let text: Text
        
        switch self {
        case .didLoad:
            text = Text("ad did load")
        case .didFailToLoadWithError:
            text = Text("ad did fail to load")
        case .didFailToShowWithError:
            text = Text("ad did fail to show")
        case .didShow:
            text = Text("ad did show")
        case .didOpen:
            text = Text("ad did open")
        case .didClose:
            text = Text("ad did close")
        case .didClick:
            text = Text("ad did click")
        }
        
        return Text("(level play)").italic() + Text(" ") + text
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didLoad(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didFailToLoadWithError(let error):
            text = "Error: " + (error?.localizedDescription ?? "-")
        case .didFailToShowWithError(let error, let ad):
            text = "Ad: " + (ad?.text ?? "-") + " error: " + (error?.localizedDescription ?? "-")
        case .didOpen(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClose(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didShow(let ad):
            text = "Ad: " + (ad?.text ?? "-")
        case .didClick(let ad):
            text = "Ad: " + (ad?.text ?? "-")
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
