//
//  ContentViewModel.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import BidOnDecoratorIronSource
import BidOn
import Combine
import SwiftUI


final class HomeViewModel: ObservableObject {
    private typealias RewardedVideoEvent = BNLevelPlayRewardedVideoPublisher.Event
    private typealias InterstitialEvent = BNLevelPlayInterstitialPublisher.Event
    private typealias AuctionEvent = BNISAuctionPublisher.Event

    @Published var events: [AdEventModel] = []
    
    @Published var rewardedVideoState = AdState.idle
    @Published var interstitialState = AdState.idle
    
    @Published var resolution = Resolution.default
    
    private var controller: UIViewController! { UIApplication.shared.topViewContoller }
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        Publishers.MergeMany([
            IronSource
                .bid
                .rewardedVideoPublisher
                .map { AdEventModel(adType: .rewardedVideo, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .interstitialPublisher
                .map { AdEventModel(adType: .interstitial, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .levelPlayRewardedVideoPublisher
                .map { AdEventModel(adType: .rewardedVideo, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .levelPlayInterstitialPublisher
                .map { AdEventModel(adType: .interstitial, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .auctionRewardedVideoPublisher
                .map { AdEventModel(adType: .rewardedVideo, event: $0) }
                .eraseToAnyPublisher(),
            IronSource
                .bid
                .auctionInterstitialPublisher
                .map { AdEventModel(adType: .interstitial, event: $0) }
                .eraseToAnyPublisher()
        ])
        .receive(on: DispatchQueue.main)
        .sink { event in
            withAnimation { [weak self] in
                self?.events.append(event)
            }
        }
        .store(in: &cancellables)
        
        $events
            .compactMap { $0.last?.event as? RewardedVideoEvent }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                var state = self.rewardedVideoState
                switch event {
                case .hasNoAvailableAd:
                    state = .failed
                case .hasAvailableAd:
                    state = .ready
                case .didOpen:
                    state = .presenting
                case .didClose:
                    state = .idle
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.rewardedVideoState = state
                }
            }
            .store(in: &cancellables)
        
        $events
            .compactMap { $0.last?.event as? InterstitialEvent }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                var state = self.interstitialState
                switch event {
                case .didFailToLoadWithError:
                    state = .failed
                case .didLoad:
                    state = .ready
                case .didShow:
                    state = .presenting
                case .didClose:
                    state = .idle
                default: break
                }
                
                withAnimation { [unowned self] in
                    self.interstitialState = state
                }
            }
            .store(in: &cancellables)
        
        $events
            .compactMap { $0.last }
            .filter { $0.adType == .interstitial }
            .compactMap { $0.event as? AuctionEvent }
            .sink { [unowned self] event in
                var state = self.interstitialState
                switch event {
                case .didStartAuction: state = .loading
                default: break
                }
                withAnimation { [unowned self] in
                    self.interstitialState = state
                }
            }
            .store(in: &cancellables)
        
        $events
            .compactMap { $0.last }
            .filter { $0.adType == .rewardedVideo }
            .compactMap { $0.event as? AuctionEvent }
            .sink { [unowned self] event in
                var state = self.rewardedVideoState
                switch event {
                case .didStartAuction: state = .loading
                default: break
                }
                withAnimation { [unowned self] in
                    self.rewardedVideoState = state
                }
            }
            .store(in: &cancellables)
        
        $resolution
            .map { $0.resolver }
            .sink {
                IronSource.bid.setInterstitialAuctionResolver($0)
                IronSource.bid.setRewardedVideoAuctionResolver($0)
                IronSource.bid.setBannerAuctionResolver($0)
            }
            .store(in: &cancellables)
    }
    
    func loadInterstitial() {
        withAnimation { [unowned self] in
            self.interstitialState = .loading
        }
        IronSource.loadInterstitial()
    }
    
    func showInterstitial() {
        IronSource.bid.showInterstitial(with: controller)
    }
    
    func loadRewardedVideo() {
        withAnimation { [unowned self] in
            self.rewardedVideoState = .loading
        }
        IronSource.loadRewardedVideo()
    }
    
    func showRewardedVideo() {
        IronSource.bid.showRewardedVideo(with: controller)
    }
}
