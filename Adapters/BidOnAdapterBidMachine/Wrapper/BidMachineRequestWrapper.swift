//
//  Request.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation
import BidMachine
import BidOn



final class BidMachineRequestWrapper<T: BDMAdRequestProtocol & BDMRequest>: NSObject, BDMRequestDelegate {
    let request: T
    
    private var response: DemandProviderResponse?
    
    init(request: T) {
        self.request = request
        super.init()
    }
    
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        self.response = response
        
        request.priceFloors = [pricefloor.bdm]
        request.perform(with: self)
    }
    
    func request(_ request: BDMRequest, failedWithError error: Error) {
        response?(.failure(MediationError(bdmError: error)))
        response = nil
    }
    
    func request(_ request: BDMRequest, completeWithAd adObject: BDMAdProtocol) {
        response?(.success(BidMachineAd(adObject)))
        response = nil
    }
    
    func notify(_ event: AuctionEvent) {
        switch (event) {
        case .win:
            request.notifyMediationWin()
        case .lose(let ad):
            request.notifyMediationLoss(ad.dsp, ecpm: ad.price as NSNumber)
        }
    }
    
    func cancel(_ reason: DemandProviderCancellationReason) {
        defer { response = nil }
        switch reason {
        case .timeoutReached: response?(.failure(.bidTimeoutReached))
        case .lifecycle: response?(.failure(.auctionCancelled))
        }
    }
}


private extension Price {
    var bdm: BDMPriceFloor {
        let pricefloor = BDMPriceFloor()
        pricefloor.value = NSDecimalNumber(
            decimal: Decimal(isUnknown ? 0.01 : self)
        )
        return pricefloor
    }
}
