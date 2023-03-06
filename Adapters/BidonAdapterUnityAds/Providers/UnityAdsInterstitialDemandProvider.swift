//
//  UnityAdsInterstitialDemandProvider.swift
//  BidonAdapterUnityAds
//
//  Created by Bidon Team on 01.03.2023.
//

import Foundation
import UIKit
import Bidon
import UnityAds


final class UnityAdsInterstitialDemandProvider: NSObject, DirectDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private var ads = Set<UnityAdsAdWrapper>()
    private var response: DemandProviderResponse?
    
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        let ad = UnityAdsAdWrapper(lineItem: lineItem)
        
        self.ads.insert(ad)
        self.response = response
        
        UnityAds.load(
            lineItem.adUnitId,
            loadDelegate: self
        )
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        if let ad = ads.first(where: { $0.adUnitId == ad.adUnitId }) {
            response(.success(ad))
        } else {
            response(.failure(.noFill))
        }
    }
    
    func notify(ad: Ad, event: Bidon.AuctionEvent) {}
}


extension UnityAdsInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: Ad, from viewController: UIViewController) {
        guard let ad = ads.first(where: { $0.adUnitId == ad.adUnitId }) else { return }
        UnityAds.show(
            viewController,
            placementId: ad.lineItem.adUnitId,
            showDelegate: self
        )
    }
}


extension UnityAdsInterstitialDemandProvider: RewardedAdDemandProvider {}


extension UnityAdsInterstitialDemandProvider: UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        guard let ad = ads.first(where: { $0.adUnitId == placementId }) else { return }
        response?(.success(ad))
        response = nil
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        guard let ad = ads.first(where: { $0.adUnitId == placementId }) else { return }
        ads.remove(ad)
        response?(.failure(MediationError(error)))
        response = nil
    }
}


extension UnityAdsInterstitialDemandProvider: UnityAdsShowDelegate {
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        guard let ad = ads.first(where: { $0.adUnitId == placementId }) else { return }
        ads.remove(ad)
        
        defer { delegate?.providerDidHide(self) }
        
        switch state {
        case .showCompletionStateCompleted:
            rewardDelegate?.provider(self, didReceiveReward: EmptyReward())
        default:
            break
        }
        
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        guard let ad = ads.first(where: { $0.adUnitId == placementId }) else { return }
        ads.remove(ad)
        delegate?.providerDidFailToDisplay(self, error: .message(message))
    }
    
    func unityAdsShowStart(_ placementId: String) {
        guard let ad = ads.first(where: { $0.adUnitId == placementId }) else { return }
        let revenue = AdRevenueWrapper(eCPM: ad.eCPM, wrapped: ad)
        revenueDelegate?.provider(self, didPay: revenue, ad: ad)
        delegate?.providerWillPresent(self)
        
    }
    
    func unityAdsShowClick(_ placementId: String) {
        guard ads.contains(where: { $0.adUnitId == placementId }) else { return }
        delegate?.providerDidClick(self)
    }
}
