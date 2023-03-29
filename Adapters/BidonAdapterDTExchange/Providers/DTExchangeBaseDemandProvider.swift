//
//  DTExchangeInterstitialDemandProvider.swift
//  BidonAdapterDTExchange
//
//  Created by Bidon Team on 27.02.2023.
//

import Foundation
import Bidon
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
        
        adSpot.fetchAd { adSpot, model, error in
            guard let adSpot = adSpot, error == nil else {
                response(.failure(.noBid))
                return
            }
    
            response(.success(adSpot))
        }
        
        self.adSpot = adSpot
    }
    
    func fill(ad: IAAdSpot, response: @escaping DemandProviderResponse) {
        response(.success(ad))
    }
    
    func notify(ad: IAAdSpot, event: AuctionEvent) {}
}
