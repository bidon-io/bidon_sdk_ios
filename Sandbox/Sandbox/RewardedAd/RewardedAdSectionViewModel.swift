//
//  RewardedAdSectionViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 26.08.2022.
//

import Foundation
import Combine
import SwiftUI
import BidOn


final class RewardedAdSectionViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case error
        case presenting
        case presentationError
    }
    
    @Published var state: State = .idle
    @Published var events: [AdEventModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var rewardedAd: RewardedAd = {
        let rewardedAd = RewardedAd()
        subsctibe(rewardedAd)
        return rewardedAd
    }()
    
    func load() {
        withAnimation { [unowned self] in
            self.state = .loading
        }
        
        rewardedAd.loadAd()
    }
    
    func subsctibe(_ rewardedAd: RewardedAd) {
        rewardedAd
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .didLoadAd:
                    withAnimation { [unowned self] in
                        self.state = .idle
                    }
                case .didFailToLoadAd:
                    withAnimation { [unowned self] in
                        self.state = .error
                    }
                case .didFailToPresentAd:
                    withAnimation { [unowned self] in
                        self.state = .presentationError
                    }
                case .willPresentAd:
                    withAnimation { [unowned self] in
                        self.state = .presenting
                    }
                case .didDismissAd:
                    withAnimation { [unowned self] in
                        self.state = .idle
                    }
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.events.append(AdEventModel(event))
                }
            }
            .store(in: &cancellables)
    }
    
    func show() {
        rewardedAd.show(from: UIApplication.shared.bd.topViewcontroller!)
    }
}
