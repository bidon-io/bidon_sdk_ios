//
//  DTExchangeInterstitialDemandProvider.swift
//  BidOnAdapterDTExchange
//
//  Created by Stas Kochkin on 27.02.2023.
//

import Foundation
import BidOn
import IASDKCore



class DTExchangeBaseDemandProvider<Controller: IAUnitController>: NSObject {
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private(set) var adSpot: IAAdSpot?
    
    open func unitController() -> Controller {
        fatalError("DTExchange base demand provider can't provide unit controller")
    }
}


extension DTExchangeBaseDemandProvider: DirectDemandProvider {
    func bid(_ lineItem: LineItem, response: @escaping DemandProviderResponse) {
        let adRequest = IAAdRequest.build { builder in
            builder.spotID = lineItem.adUnitId
        }
        
        guard let adRequest = adRequest else {
            response(.failure(.incorrectAdUnitId))
            return
        }
        
        let adSpot = IAAdSpot.build { builder in
            builder.adRequest = adRequest
            builder.addSupportedUnitController(self.unitController())
        }
        
        guard let adSpot = adSpot else {
            response(.failure(.unscpecifiedException))
            return
        }
        
        adSpot.fetchAd { adSpot, _, _ in
            guard let adSpot = adSpot else {
                response(.failure(.noBid))
                return
            }
            
            let wrapper = DTExchangeAdWrapper(
                lineItem: lineItem,
                adSpot: adSpot
            )
            
            response(.success(wrapper))
        }
        
        self.adSpot = adSpot
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        if let ad = ad as? DTExchangeAdWrapper {
            response(.success(ad))
        } else {
            response(.failure(.incorrectAdUnitId))
        }
    }
        
    func notify(ad: Ad, event: AuctionEvent) {}
}
