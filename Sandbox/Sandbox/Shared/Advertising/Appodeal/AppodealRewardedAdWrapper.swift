//
//  AppodealRewardedAdAdvertisingWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 15.02.2023.
//

import Foundation
import Appodeal
import BidOn
import Combine
import SwiftUI


final class AppodealRewardedAdWrapper: BaseFullscreenAdWrapper {
    private var bidOnRewardedAd: BidOn.RewardedAd?
    
    override init() {
        super.init()
        Appodeal.setRewardedVideoDelegate(self)
    }
    
    override func _load() {
        performMediation()
    }
    
    override func _show() {
        guard
            let controller = UIApplication.shared.bd.topViewcontroller
        else {
            resumeShowingContinuation(throwing: AppodealAdServiceError.invalidPresentationState)
            return
        }
        
        if let rewardedAd = bidOnRewardedAd, rewardedAd.isReady {
            rewardedAd.show(from: controller)
        } else {
            Appodeal.showAd(.rewardedVideo, rootViewController: controller)
        }
    }
    
    private func performMediation() {
        Appodeal.cacheAd(.rewardedVideo)
    }
    
    private func performPostBid() {
        let pricefloor = max(pricefloor, Appodeal.predictedEcpm(for: .rewardedVideo))
        let rewardedAd = BidOn.RewardedAd()
        rewardedAd.delegate = self
        rewardedAd.loadAd(with: pricefloor)
        self.bidOnRewardedAd = rewardedAd
    }
}


extension AppodealRewardedAdWrapper: AppodealRewardedVideoDelegate {
    func rewardedVideoDidLoadAdIsPrecache(_ precache: Bool) {
        send(
            event: "Appodeal did load \(precache ? "precache" : "") ad",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
        
        performPostBid()
    }
    
    func rewardedVideoDidFailToLoadAd() {
        send(
            event: "Appodeal did fail to load ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
        
        performPostBid()
    }
    
    func rewardedVideoDidFailToPresentWithError(_ error: Error) {
        send(
            event: "Appodeal did fail to present ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
        
        resumeLoadingContinuation(throwing: AppodealAdServiceError.invalidPresentationState)
    }
    
    func rewardedVideoWillDismissAndWasFullyWatched(_ wasFullyWatched: Bool) {
        send(
            event: "Appodeal did dismiss ad",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
        
        resumeShowingContinuation()
    }
}


extension AppodealRewardedAdWrapper {
    override func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {
        super.adObject(adObject, didLoadAd: ad)
        
        resumeLoadingContinuation()
    }
    
    override func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {
        super.adObject(adObject, didFailToLoadAd: error)
        
        if Appodeal.isReadyForShow(with: .rewardedVideo) {
            resumeLoadingContinuation()
        } else {
            resumeLoadingContinuation(throwing: AppodealAdServiceError.noFill)
        }
    }

    
    override func fullscreenAd(_ fullscreenAd: BidOn.FullscreenAdObject, didFailToPresentAd error: Error) {
        super.fullscreenAd(fullscreenAd, didFailToPresentAd: error)
        
        resumeShowingContinuation(throwing: AppodealAdServiceError.invalidPresentationState)
    }
    
    override func fullscreenAd(_ fullscreenAd: BidOn.FullscreenAdObject, didDismissAd ad: BidOn.Ad) {
        super.fullscreenAd(fullscreenAd, didDismissAd: ad)
        
        resumeShowingContinuation()
    }
}
