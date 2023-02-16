//
//  RawRewardedAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 16.02.2023.
//

import Foundation
import BidOn
import Combine
import SwiftUI



final class RawRewardedAdWrapper: BaseFullscreenAdWrapper {
    private var bidOnRewardedAd: BidOn.RewardedAd?
    
    override func _load() {
        let rewardedAd = BidOn.RewardedAd()
        rewardedAd.delegate = self
        rewardedAd.loadAd(with: pricefloor)
        self.bidOnRewardedAd = rewardedAd
    }
    
    override func _show() {
        guard
            let controller = UIApplication.shared.bd.topViewcontroller
        else {
            resumeShowingContinuation(throwing: RawAdServiceError.invalidPresentationState)
            return
        }
        
        if let rewardedAd = bidOnRewardedAd, rewardedAd.isReady {
            rewardedAd.show(from: controller)
        } else {
            resumeShowingContinuation(throwing: RawAdServiceError.invalidPresentationState)
        }
    }
}


extension RawRewardedAdWrapper {
    override func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {
        super.adObject(adObject, didLoadAd: ad)
        
        resumeLoadingContinuation()
    }
    
    override func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {
        super.adObject(adObject, didFailToLoadAd: error)
        
        resumeLoadingContinuation(throwing: AppodealAdServiceError.noFill)
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
