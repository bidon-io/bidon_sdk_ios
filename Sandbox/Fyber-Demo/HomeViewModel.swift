//
//  HomeViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import Combine
import BidOnDecoratorFyber
import SwiftUI


final class HomeViewModel: ObservableObject {
    @Published var events: [AdEventModel] = []
    
    @Published var interstitial = InterstitialViewModel()
    @Published var rewarded = RewardedViewModel()
    @Published var banner = BannerViewModel()
    
    @Published var resolution: Resolution = .default
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    func subscribe() {
        Publishers.MergeMany([
            BNFYBInterstitial
                .publisher
                .map { AdEventModel(adType: .interstitial, event: $0) }
                .eraseToAnyPublisher(),
            BNFYBInterstitial
                .auctionPublisher
                .map { AdEventModel(adType: .interstitial, event: $0) }
                .eraseToAnyPublisher(),
            BNFYBRewarded
                .publisher
                .map { AdEventModel(adType: .rewardedVideo, event: $0) }
                .eraseToAnyPublisher(),
            BNFYBRewarded
                .auctionPublisher
                .map { AdEventModel(adType: .rewardedVideo, event: $0) }
                .eraseToAnyPublisher(),
            BNFYBBanner
                .publisher
                .map { BNFYBBannerPublisher.NoViewEvent($0) }
                .map { AdEventModel(adType: .banner, event: $0) }
                .eraseToAnyPublisher(),
            BNFYBBanner
                .auctionPublisher
                .map { AdEventModel(adType: .banner, event: $0) }
                .eraseToAnyPublisher(),
        ])
        .receive(on: DispatchQueue.main)
        .sink { event in
            withAnimation { [unowned self] in
                self.events.append(event)
            }
        }
        .store(in: &cancellables)
        
        $events
            .map { $0.filter { $0.adType == .interstitial } }
            .assign(to: \.events, on: interstitial)
            .store(in: &cancellables)
        
        $events
            .map { $0.filter { $0.adType == .rewardedVideo } }
            .assign(to: \.events, on: rewarded)
            .store(in: &cancellables)
        
        $events
            .map { $0.filter { $0.adType == .banner } }
            .assign(to: \.events, on: banner)
            .store(in: &cancellables)
        
        $resolution
            .map { $0.resolver }
            .sink { resolver in
                BNFYBBanner.resolver = resolver
                BNFYBInterstitial.resolver = resolver
                BNFYBRewarded.resolver = resolver
            }
            .store(in: &cancellables)
    }
}
