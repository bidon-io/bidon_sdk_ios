//
//  MintegralBiddingInterstitialDemandProvider.swift
//  BidonAdapterMintegral
//
//  Created by Bidon Team on 05.07.2023.
//

import Foundation
import Bidon
import MTGSDK
import MTGSDKBidding
import MTGSDKNewInterstitial


extension MTGNewInterstitialBidAdManager: DemandAd {
    public var id: String { currentUnitId }
    public var networkName: String { MintegralDemandSourceAdapter.identifier }
    public var dsp: String? { nil }
}


final class MintegralBiddingInterstitialDemandProvider: MintegralBiddingBaseDemandProvider<MTGNewInterstitialBidAdManager> {
    private var response: Bidon.DemandProviderResponse?
    
    private var interstitial: MTGNewInterstitialBidAdManager!
    
    override func prepareBid(
        data: BiddingResponse,
        response: @escaping DemandProviderResponse
    ) {
        
        self.response = response
        
        interstitial = MTGNewInterstitialBidAdManager(
            placementId: data.placementId,
            unitId: data.unitId,
            delegate: self
        )
        interstitial.loadAd(withBidToken: data.payload)
    }
}


extension MintegralBiddingInterstitialDemandProvider: InterstitialDemandProvider {
    func show(ad: MTGNewInterstitialBidAdManager, from viewController: UIViewController) {
        if interstitial.isAdReady() {
            interstitial.show(from: viewController)
        } else {
            delegate?.provider(self, didFailToDisplayAd: ad, error: .invalidPresentationState)
        }
    }
}


extension MintegralBiddingInterstitialDemandProvider: MTGNewInterstitialBidAdDelegate {
    func newInterstitialBidAdLoadSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        response?(.success(adManager))
        response = nil
    }
    
    func newInterstitialBidAdLoadFail(_ error: Error, adManager: MTGNewInterstitialBidAdManager) {
        response?(.failure(.noFill))
        response = nil
    }
    
    func newInterstitialBidAdShowSuccess(_ adManager: MTGNewInterstitialBidAdManager) {
        delegate?.providerWillPresent(self)
        
        revenueDelegate?.provider(self, didLogImpression: adManager)
    }
    
    func newInterstitialBidAdShowFail(_ error: Error, adManager: MTGNewInterstitialBidAdManager) {
        delegate?.provider(self, didFailToDisplayAd: adManager, error: .generic(error: error))
    }
    
    func newInterstitialBidAdClicked(_ adManager: MTGNewInterstitialBidAdManager) {
        delegate?.providerDidClick(self)
    }
    
    func newInterstitialBidAdDismissed(withConverted converted: Bool, adManager: MTGNewInterstitialBidAdManager) {
        delegate?.providerDidHide(self)
    }
}
