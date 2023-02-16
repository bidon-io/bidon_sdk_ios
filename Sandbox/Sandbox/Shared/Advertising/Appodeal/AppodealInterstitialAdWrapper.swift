//
//  AppodealAdvertisingServiceInterstitialHelper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 14.02.2023.
//

import Foundation
import Appodeal
import BidOn
import Combine
import SwiftUI


final class AppodealInterstitialAdWrapper: BaseFullscreenAdWrapper {
    private var bidOnInterstitial: BidOn.Interstitial?
    
    override init() {
        super.init()
        Appodeal.setInterstitialDelegate(self)
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
        
        if let interstitial = bidOnInterstitial, interstitial.isReady {
            interstitial.show(from: controller)
        } else {
            Appodeal.showAd(.interstitial, rootViewController: controller)
        }
    }
    
    private func performMediation() {
        Appodeal.cacheAd(.interstitial)
    }
    
    private func performPostBid() {
        let pricefloor = max(pricefloor, Appodeal.predictedEcpm(for: .interstitial))
        let interstitial = BidOn.Interstitial()
        interstitial.delegate = self
        interstitial.loadAd(with: pricefloor)
        self.bidOnInterstitial = interstitial
    }
}


extension AppodealInterstitialAdWrapper: AppodealInterstitialDelegate {
    func interstitialDidLoadAdIsPrecache(_ precache: Bool) {
        send(
            event: "Appodeal did load \(precache ? "precache" : "") ad",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
        
        performPostBid()
    }
    
    func interstitialDidFailToLoadAd() {
        send(
            event: "Appodeal did fail to load ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
        
        performPostBid()
    }
    
    func interstitialDidFailToPresent() {
        send(
            event: "Appodeal did fail to present ad",
            detail: "",
            bage: "star.fill",
            color: .red
        )
        
        resumeLoadingContinuation(throwing: AppodealAdServiceError.invalidPresentationState)
    }
    
    func interstitialDidDismiss() {
        send(
            event: "Appodeal did dismiss ad",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
        
        resumeShowingContinuation()
    }
}


extension AppodealInterstitialAdWrapper {
    override func adObject(_ adObject: BidOn.AdObject, didLoadAd ad: BidOn.Ad) {
        super.adObject(adObject, didLoadAd: ad)
        
        resumeLoadingContinuation()
    }
    
    override func adObject(_ adObject: BidOn.AdObject, didFailToLoadAd error: Error) {
        super.adObject(adObject, didFailToLoadAd: error)
        
        if Appodeal.isReadyForShow(with: .interstitial) {
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
