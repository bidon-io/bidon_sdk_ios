//
//  AdViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import Combine
import SwiftUI
import BidOnDecoratorFyber


class AdViewModel: ObservableObject {
    @Published var events: [AdEventModel] = []
    
    @Published private(set) var state: AdState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        $events
            .compactMap { $0.last?.event as? BNFYBRewardedPublisher.Event }
            .sink { [unowned self] event in
                var state = self.state
                
                switch event {
                case .rewardedWillRequest:
                    state = .loading
                case .rewardedIsAvailable:
                    state = .ready
                case .rewardedIsUnavailable:
                    state = .failed
                case .rewardedDidShow:
                    state = .presenting
                case .rewardedDidFailToShow:
                    state = .failed
                case .rewardedDidDismiss:
                    state = .idle
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.state = state
                }
            }
            .store(in: &cancellables)
        
        $events
            .compactMap { $0.last?.event as? BNFYBInterstitialPublisher.Event }
            .sink { [unowned self] event in
                var state = self.state
                
                switch event {
                case .interstitialWillRequest:
                    state = .loading
                case .interstitialIsAvailable:
                    state = .ready
                case .interstitialIsUnavailable:
                    state = .failed
                case .interstitialDidShow:
                    state = .presenting
                case .interstitialDidFailToShow:
                    state = .failed
                case .interstitialDidDismiss:
                    state = .idle
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.state = state
                }
            }
            .store(in: &cancellables)
    }
}

