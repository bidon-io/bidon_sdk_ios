//
//  AppodealAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 15.02.2023.
//

import Foundation
import Combine
import SwiftUI
import Appodeal
import BidOn



protocol AppodealAdWrapper {
    var adEventSubject: PassthroughSubject<AdEventModel, Never> { get }
    
    var adType: AdType { get }
    
    func load(pricefloor: Double) async throws
}


protocol AppodealFullscreenAdWrapper: AppodealAdWrapper {
    func show() async throws
}


extension AppodealAdWrapper {
    func send(
        event title: String,
        detail: String,
        bage: String,
        color: Color
    ) {
        let adEvent = AdEventModel(
            date: Date(),
            adType: .interstitial,
            title: title,
            subtitle: detail,
            bage: bage,
            color: color
        )
        
        adEventSubject.send(adEvent)
    }
}


class AppodealDefaultFullscreenAdWrapper: NSObject, AppodealFullscreenAdWrapper {
    final let adEventSubject = PassthroughSubject<AdEventModel, Never>()
    
    private var loadingContinuation: CheckedContinuation<Void, Error>?
    private var showingContinuation: CheckedContinuation<Void, Error>?
    
    final private(set) var pricefloor: Double = .zero
    
    open var adType: AdType { fatalError("Undefined ad type") }
    
    final func load(pricefloor: Double) async throws {
        self.pricefloor = pricefloor
        try await withCheckedThrowingContinuation { [unowned self] continuation in
            self.loadingContinuation = continuation
            DispatchQueue.main.async { [unowned self] in
                self._load()
            }
        }
    }
    
    final func show() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.showingContinuation = continuation
            DispatchQueue.main.async { [unowned self] in
                self._show()
            }
        }
    }
    
    open func _load() {
        fatalError("Not implemented")
    }
    
    open func _show() {
        fatalError("")
    }
    
    final func resumeLoadingContinuation(throwing error: Error) {
        loadingContinuation?.resume(throwing: error)
        loadingContinuation = nil
    }
    
    final func resumeLoadingContinuation() {
        loadingContinuation?.resume()
        loadingContinuation = nil
    }
    
    final func resumeShowingContinuation(throwing error: Error) {
        showingContinuation?.resume(throwing: error)
        showingContinuation = nil
    }
    
    final func resumeShowingContinuation() {
        showingContinuation?.resume()
        showingContinuation = nil
    }
}


extension AppodealDefaultFullscreenAdWrapper: BidOn.RewardedAdDelegate {
    func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {
        send(
            event: "BidOn did load ad",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {
        send(
            event: "BidOn did fail to load ad",
            detail: error.localizedDescription,
            bage: "star.fill",
            color: .red
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordImpression ad: Ad
    ) {
        send(
            event: "BidOn did record impression",
            detail: ad.text,
            bage: "flag.fill",
            color: .accentColor
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didRecordClick ad: Ad
    ) {
        send(
            event: "BidOn did record click",
            detail: ad.text,
            bage: "flag.fill",
            color: .accentColor
        )
    }
    
    func adObjectDidStartAuction(
        _ adObject: AdObject
    ) {
        send(
            event: "BidOn did start auction",
            detail: "",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didStartAuctionRound auctionRound: String,
        pricefloor: Price
    ) {
        send(
            event: "BidOn did start auction round \(auctionRound)",
            detail: "Pricefloor: \(pricefloor)",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didReceiveBid ad: Ad
    ) {
        send(
            event: "BidOn did receive bid",
            detail: ad.text,
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuctionRound auctionRound: String
    ) {
        send(
            event: "BidOn did complete auction round \(auctionRound)",
            detail: "",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didCompleteAuction winner: Ad?
    ) {
        send(
            event: "BidOn did complete auction",
            detail: winner.map { "Winner ad is \($0.text)" } ?? "No winner",
            bage: "flag.fill",
            color: .secondary
        )
    }
    
    func adObject(
        _ adObject: AdObject,
        didPayRevenue ad: Ad
    ) {
        send(
            event: "BidOn did pay revenue",
            detail: ad.text,
            bage: "cart.fill",
            color: .primary
        )
    }
    
    func fullscreenAd(_ fullscreenAd: BidOn.FullscreenAdObject, willPresentAd ad: BidOn.Ad) {
        send(
            event: "BidOn will present ad",
            detail: ad.text,
            bage: "star.fill",
            color: .accentColor
        )
    }
    
    func fullscreenAd(_ fullscreenAd: BidOn.FullscreenAdObject, didFailToPresentAd error: Error) {
        send(
            event: "BidOn did fail to present ad",
            detail: error.localizedDescription,
            bage: "star.fill",
            color: .red
        )
    }
    
    func fullscreenAd(_ fullscreenAd: BidOn.FullscreenAdObject, didDismissAd ad: BidOn.Ad) {
        send(
            event: "BidOn did dismiss ad",
            detail: ad.text,
            bage: "star.fill",
            color: .secondary
        )
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdObject, didRewardUser reward: Reward) {
        send(
            event: "BidOn did reward user",
            detail: "Reward is \(reward.amount) \(reward.label)",
            bage: "gift",
            color: .orange
        )
    }
}
