//
//  RawInterstitialAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 16.02.2023.
//

import Foundation
import BidOn
import Combine
import SwiftUI



final class RawInterstitialAdWrapper: BaseFullscreenAdWrapper {
    private var bidOnInterstitial: BidOn.Interstitial?
    
    override func _load() {
        let interstitial = BidOn.Interstitial()
        interstitial.delegate = self
        interstitial.loadAd(with: pricefloor)
        self.bidOnInterstitial = interstitial
    }
    
    override func _show() {
        guard
            let controller = UIApplication.shared.bd.topViewcontroller
        else {
            resumeShowingContinuation(throwing: RawAdServiceError.invalidPresentationState)
            return
        }
        
        if let interstitial = bidOnInterstitial, interstitial.isReady {
            interstitial.showAd(from: controller)
        } else {
            resumeShowingContinuation(throwing: RawAdServiceError.invalidPresentationState)
        }
    }
}


extension RawInterstitialAdWrapper {
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
