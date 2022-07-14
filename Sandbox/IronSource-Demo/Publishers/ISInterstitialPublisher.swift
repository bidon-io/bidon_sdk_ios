//
//  ISInterstitialPublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator
import SwiftUI


struct ISInterstitialPublisher: Publisher {
    typealias Output = AdEventModel
    typealias Failure = Never
    
    enum Event {
        case didLoad
        case didFailToLoadWithError(error: Error!)
        case didFailToShowWithError(error: Error!)
        case didOpen
        case didShow
        case didClose
        case didStart
        case didClick
    }
    
    private let delegate: (ISInterstitialDelegate) -> ()
        
    init(_ delegate: @escaping (ISInterstitialDelegate) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ISInterstitialDelegateSubscribtion(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class ISInterstitialDelegateSubscribtion<S>: NSObject, Subscription, ISInterstitialDelegate
where S : Subscriber, S.Input == AdEventModel {
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func produce(_ event: ISInterstitialPublisher.Event) {
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
    
    func interstitialDidLoad() {
        produce(.didLoad)
    }
    
    func interstitialDidFailToLoadWithError(_ error: Error!) {
        produce(.didFailToLoadWithError(error: error))
    }
    
    func interstitialDidOpen() {
        produce(.didOpen)
    }
    
    func interstitialDidClose() {
        produce(.didClose)
    }
    
    func interstitialDidShow() {
        produce(.didShow)
    }
    
    func interstitialDidFailToShowWithError(_ error: Error!) {
        produce(.didFailToShowWithError(error: error))
    }
    
    func didClickInterstitial() {
        produce(.didClose)
    }
}


extension IronSourceDecorator.Proxy {
    var interstitialPublisher: AnyPublisher<AdEventModel, Never> {
        return ISInterstitialPublisher { [unowned self] delegate in
            self.setInterstitialDelegate(delegate)
        }
        .eraseToAnyPublisher()
    }
}


extension ISInterstitialPublisher.Event: AdEventViewRepresentable {
    var title: Text {
        switch self {
        case .didLoad:
            return Text("ad did load")
        case .didFailToLoadWithError:
            return Text("ad did fail to load")
        case .didFailToShowWithError:
            return Text("ad did fail to show")
        case .didOpen:
            return Text("ad did open")
        case .didClose:
            return Text("ad did close")
        case .didStart:
            return Text("ad did start")
        case .didClick:
            return Text("ad did click")
        case .didShow:
            return Text("ad did show")
        }
    }
    
    var subtitle: Text {
        let text: String
        switch self {
        case .didFailToLoadWithError(let error):
            text = "Error: \(error?.localizedDescription ?? "-")"
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
