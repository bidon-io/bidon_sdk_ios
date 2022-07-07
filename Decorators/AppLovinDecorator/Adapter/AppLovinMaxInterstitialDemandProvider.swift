//
//  AppLovinDemandSourceAdapter.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 01.07.2022.
//

import Foundation
import MobileAdvertising
import AppLovinSDK


internal final class AppLovinMaxInterstitialDemandProvider: NSObject {
    struct DisplayArguments {
        var placement: String?
        var customData: String?
    }
    
    lazy var interstitial: MAInterstitialAd = {
        let interstitial: MAInterstitialAd
        
        if let sdk = sdk {
            interstitial = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier, sdk: sdk)
        } else {
            interstitial = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
        }
        
        interstitial.delegate = self
        
        return interstitial
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var adReviewdelegate: MAAdReviewDelegate?
    weak var revenueDelegate: MAAdRevenueDelegate?
    
    private let adUnitIdentifier: String
    private let sdk: ALSdk?
    private let displayArguments: () -> DisplayArguments?
    private var response: DemandProviderResponse?
    
    init(
        adUnitIdentifier: String,
        displayArguments: @escaping @autoclosure () -> DisplayArguments?,
        sdk: ALSdk?
    ) {
        self.sdk = sdk
        self.displayArguments = displayArguments
        self.adUnitIdentifier = adUnitIdentifier
    }
}


extension AppLovinMaxInterstitialDemandProvider: InterstitialDemandProvider {
    func request(pricefloor: Price) async throws -> Ad {
        fatalError()
    }

    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        interstitial.load()
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        let args = displayArguments()
        interstitial.show(
            forPlacement: args?.placement,
            customData: args?.customData,
            viewController: viewController
        )
    }
    
    func notify(_ event: AuctionEvent) {}
}

 
extension AppLovinMaxInterstitialDemandProvider: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        response?(ad.wrapped, nil)
        response = nil
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        response?(nil, error)
        response = nil
    }
    
    func didDisplay(_ ad: MAAd) {
        delegate?.provider(self, didPresent: ad.wrapped)
    }
    
    func didHide(_ ad: MAAd) {
        delegate?.provider(self, didHide: ad.wrapped)
    }
    
    func didClick(_ ad: MAAd) {
        delegate?.provider(self, didClick: ad.wrapped)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        delegate?.provider(self, didFailToDisplay: ad.wrapped, error: error)
    }
}


