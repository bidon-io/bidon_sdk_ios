//
//  ISInitializationDelegatePublisher.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import Combine
import IronSource
import IronSourceDecorator


struct ISInitializationDelegatePublisher: Publisher {
    typealias Output = ()
    typealias Failure = Never
    
    private let delegate: (ISInitializationDelegate?) -> ()
        
    init(_ delegate: @escaping (ISInitializationDelegate?) -> ()) {
        self.delegate = delegate
    }
    
    func receive<S>(subscriber: S)
    where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = ISInitializationDelegateSubscription(
            subscriber: subscriber
        )
        
        delegate(subscription)
        
        subscriber.receive(subscription: subscription)
    }
}


final fileprivate
class ISInitializationDelegateSubscription<S>: NSObject, Subscription, ISInitializationDelegate
where S : Subscriber, S.Input == Void {
    
    private var subscriber: S?
    
    var demand: Subscribers.Demand = .none
    
    init(subscriber: S) {
        self.subscriber = subscriber
        super.init()
    }
    
    func trigger() {
        guard let subscriber = subscriber else { return }
                    
        demand -= 1
        demand += subscriber.receive()
    }
    
    func cancel() {
        demand = .none
        subscriber = nil
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func initializationDidComplete() {
        trigger()
    }
}


extension IronSourceDecorator.Proxy {
    func initializePublisher(
        _ appKey: String,
        adUnits: [String]
    ) -> AnyPublisher<Void, Never> {
        return ISInitializationDelegatePublisher { [unowned self] delegate in
            self.initWithAppKey(
                appKey,
                adUnits: adUnits,
                delegate: delegate
            )
        }
        .eraseToAnyPublisher()
    }
}
