//
//  GoogleMobileAdsInterstitialDemandProvider.swift
//  GoogleMobileAdsAdapter
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation
import MobileAdvertising
import GoogleMobileAds
import UIKit


internal final class GoogleMobileAdsInterstitialDemandProvider: NSObject {
    private let item: (Price) -> LineItem?
    
    private var _item: LineItem?
    private var interstitial: GADInterstitialAd? {
        didSet {
            interstitial?.fullScreenContentDelegate = self
        }
    }
    
    weak var delegate: DemandProviderDelegate?
    
    init(item: @escaping (Price) -> LineItem?) {
        self.item = item
        super.init()
    }
}


extension GoogleMobileAdsInterstitialDemandProvider: InterstitialDemandProvider {
    func request(pricefloor: Price) async throws -> Ad {
        fatalError()
    }

    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        guard let item = item(pricefloor) else {
            response(nil, SDKError.message("Line item was not found for pricefloor \(pricefloor)"))
            return
        }
        
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: item.adUnitId,
            request: request
        ) { [weak self] interstitial, error in
            guard let self = self else { return }
            guard let interstitial = interstitial, error == nil else {
                response(nil, SDKError(error))
                return
            }
            
            self._item = item
            self.interstitial = interstitial
            
            response(BNGADResponseInfoWrapper(interstitial, item: item), nil)
        }
    }

    func show(ad: Ad, from viewController: UIViewController) {
        guard let interstitial = interstitial else {
            delegate?.provider(
                self,
                didFailToDisplay: ad,
                error: SDKError.invalidPresentationState
            )
            return
        }
        interstitial.present(fromRootViewController: viewController)
    }

    func notify(_ event: AuctionEvent) {}
    
    private func wrapped(ad: GADFullScreenPresentingAd) -> Ad? {
        guard
            let interstitial = interstitial,
                interstitial === ad,
                let item = _item
        else { return nil }
        
        return BNGADResponseInfoWrapper(
            interstitial,
            item: item
        )
    }
}


extension GoogleMobileAdsInterstitialDemandProvider: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didPresent: wrapped)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didFailToDisplay: wrapped, error: SDKError(error))
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didClick: wrapped)
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        guard let wrapped = wrapped(ad: ad) else { return }
        delegate?.provider(self, didHide: wrapped)
    }
}


