//
//  AdViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import SwiftUI
import AppLovinDecorator


class AdViewModel: ObservableObject {
    private typealias AuctionEvent = BNMAuctionPublisher.Event
    
    @Published var adUnitIdentifier: String = "YOUR_AD_UNIT_ID"
    @Published var events: [AdEventModel] = []
    @Published var state: AdState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    func subscribe(_ publisher: AnyPublisher<AdEventModel, Never>) {
        cancellables.removeAll()
        publisher.receive(on: DispatchQueue.main).sink { event in
            withAnimation { [unowned self] in
                self.events.append(event)
            }
        }
        .store(in: &cancellables)
        
        $events
            .compactMap { $0.last?.event as? AuctionEvent }
            .sink { [unowned self] event in
                var state = self.state
                switch event {
                case .didStartAuction:
                    state = .loading
                default:
                    break
                }
                
                withAnimation { [weak self] in
                    self?.state = state
                }
            }
            .store(in: &cancellables)
        
        // TODO: Use another aproach to update state
        adEventPublisher
            .sink { [unowned self] event in
                var state = self.state
                switch event {
                case .didLoad:
                    state = .ready
                case .didFailToLoadAd, .didFailToDisplay:
                    state = .failed
                default:
                    break
                }
                
                withAnimation { [weak self] in
                    self?.state = state
                }
            }
            .store(in: &cancellables)
        
        rewardedAdEventPublisher
            .sink { [unowned self] event in
                var state = self.state
                switch event {
                case .didLoad:
                    state = .ready
                case .didFailToLoadAd, .didFailToDisplay:
                    state = .failed
                default:
                    break
                }
                
                withAnimation { [weak self] in
                    self?.state = state
                }
            }
            .store(in: &cancellables)
        
        adViewEventPublisher
            .sink { [unowned self] event in
                var state = self.state
                switch event {
                case .didLoad:
                    state = .ready
                case .didFailToLoadAd, .didFailToDisplay:
                    state = .failed
                default:
                    break
                }
                
                withAnimation { [weak self] in
                    self?.state = state
                }
            }
            .store(in: &cancellables)
    }
    
    private var adEventPublisher: AnyPublisher<BNMAAdPublisher.Event, Never> {
        return $events
            .compactMap { $0.last?.event as? BNMAAdPublisher.Event }
            .eraseToAnyPublisher()
    }
    
    private var rewardedAdEventPublisher: AnyPublisher<BNMARewardedAdPublisher.Event, Never> {
        return $events
            .compactMap { $0.last?.event as? BNMARewardedAdPublisher.Event }
            .eraseToAnyPublisher()
    }
    
    private var adViewEventPublisher: AnyPublisher<BNMAAdViewAdPublisher.Event, Never> {
        return $events
            .compactMap { $0.last?.event as? BNMAAdViewAdPublisher.Event }
            .eraseToAnyPublisher()
    }
}
