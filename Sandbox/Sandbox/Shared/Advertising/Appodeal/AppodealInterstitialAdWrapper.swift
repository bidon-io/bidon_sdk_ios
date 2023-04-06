//
//  AppodealAdvertisingServiceInterstitialHelper.swift
//  Sandbox
//
//  Created by Bidon Team on 14.02.2023.
//

import Foundation
import Appodeal
import Bidon
import Combine
import SwiftUI


final class AppodealInterstitialAdWrapper: BaseFullscreenAdWrapper {
    private var bidOnInterstitial: Bidon.Interstitial?
    
    override var adType: AdType { .interstitial } 
    
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
            interstitial.showAd(from: controller)
        } else {
            Appodeal.showAd(.interstitial, rootViewController: controller)
        }
    }
    
    override func notify(loss ad: Ad) {
        bidOnInterstitial?.notify(
            loss: ad,
            winner: "some_appodeal_ad_network",
            eCPM: ad.eCPM + 0.01
        )
    }
    
    private func performMediation() {
        Appodeal.cacheAd(.interstitial)
    }
    
    private func performPostBid() {
        let pricefloor = max(pricefloor, Appodeal.predictedEcpm(for: .interstitial))
        let interstitial = Bidon.Interstitial()
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
    
    func interstitialDidClick() {
        send(
            event: "Appodeal did click",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
    }
    
    func interstitialWillPresent() {
        send(
            event: "Appodeal will present",
            detail: "",
            bage: "star.fill",
            color: .secondary
        )
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
    override func adObject(_ adObject: Bidon.AdObject, didLoadAd ad: Bidon.Ad) {
        super.adObject(adObject, didLoadAd: ad)
        
        resumeLoadingContinuation()
    }
    
    override func adObject(_ adObject: Bidon.AdObject, didFailToLoadAd error: Error) {
        super.adObject(adObject, didFailToLoadAd: error)
        
        if Appodeal.isReadyForShow(with: .interstitial) {
            resumeLoadingContinuation()
        } else {
            resumeLoadingContinuation(throwing: AppodealAdServiceError.noFill)
        }
    }

    
    override func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didFailToPresentAd error: Error) {
        super.fullscreenAd(fullscreenAd, didFailToPresentAd: error)
        
        resumeShowingContinuation(throwing: AppodealAdServiceError.invalidPresentationState)
    }
    
    override func fullscreenAd(_ fullscreenAd: Bidon.FullscreenAdObject, didDismissAd ad: Bidon.Ad) {
        super.fullscreenAd(fullscreenAd, didDismissAd: ad)
        
        resumeShowingContinuation()
    }
}
