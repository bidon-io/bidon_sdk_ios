//
//  GoogleMobileAdsBaseDemandProvider.swift
//  BidonAdapterGoogleMobileAds
//
//  Created by Bidon Team on 23.02.2023.
//

import Foundation
import UIKit
import GoogleMobileAds
import Bidon


class GoogleMobileAdsBaseDemandProvider<AdObject: GoogleMobileAdsDemandAd>: NSObject {
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private var response: DemandProviderResponse?
    
    open func loadAd(_ request: GADRequest, lineItem: LineItem) {
        fatalError("Base demand provider can't load any ad")
    }
    
    final func handleDidLoad(adObject: AdObject, lineItem: LineItem) {
        self.response?(.success(adObject))
        self.response = nil
    }
    
    final func handleDidFailToLoad(_ error: MediationError) {
        self.response?(.failure(error))
        self.response = nil
    }
    
    final func setupAdRevenueHandler(_ adObject: AdObject, lineItem: LineItem) {
        adObject.paidEventHandler = { [weak self, weak adObject] value in
            guard let self = self, let adObject = adObject else { return }
                        
            self.revenueDelegate?.provider(
                self,
                didPayRevenue: value.revenue,
                ad: adObject
            )
        }
    }
}


extension GoogleMobileAdsBaseDemandProvider: DirectDemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        self.response = response
        
        let request = GADRequest()
        loadAd(request, lineItem: lineItem)
    }
    
    func fill(ad: AdObject, response: @escaping DemandProviderResponse) {
        response(.success(ad))
    }
    
    func notify(ad: AdObject, event: AuctionEvent) {}
}

