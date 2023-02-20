//
//  BaseFullscreenAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 20.02.2023.
//

import Foundation
import BidOn


class BaseFullscreenAdWrapper: BaseAdWrapper, FullscreenAdWrapper {
    private var loadingContinuation: CheckedContinuation<Void, Error>?
    private var showingContinuation: CheckedContinuation<Void, Error>?
    
    final private(set) var pricefloor: Double = .zero
        
    final override func load(pricefloor: Double) async throws {
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


extension BaseFullscreenAdWrapper: BidOn.RewardedAdDelegate {
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
