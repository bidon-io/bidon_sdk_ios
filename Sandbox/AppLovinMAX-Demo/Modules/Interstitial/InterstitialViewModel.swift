//
//  InterstitialViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import Combine
import BidOnDecoratorAppLovinMax
import AppLovinSDK
import SwiftUI


final class InterstitialViewModel: AdViewModel {
    @Published var placement: String = ""
    
    private var interstitial: BNMAInterstitialAd? {
        didSet {
            guard let interstitial = interstitial else { return }
            let publisher: AnyPublisher<AdEventModel, Never> = Publishers.MergeMany([
                interstitial
                    .publisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                interstitial
                    .auctionPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                interstitial
                    .adReviewPublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher(),
                interstitial
                    .revenuePublisher
                    .map { AdEventModel(event: $0) }
                    .eraseToAnyPublisher()
            ]).eraseToAnyPublisher()
            
            subscribe(publisher)
        }
    }
    
    func load() {
        let interstital = BNMAInterstitialAd(
            adUnitIdentifier: adUnitIdentifier,
            sdk: applovin
        )
        interstital.resolver = resolver
        self.interstitial = interstital
        self.interstitial?.load()
    }
    
    func present() {
        guard let interstitial = interstitial else { return }
        interstitial.show()
    }
    
    func presentWithPlacement() {
        guard let interstitial = interstitial else { return }
        interstitial.show(forPlacement: placement)
    }
}
