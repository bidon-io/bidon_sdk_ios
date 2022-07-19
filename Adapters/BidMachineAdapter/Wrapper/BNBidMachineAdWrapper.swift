//
//  BNBidMachineAdWrapper.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation
import BidMachine
import MobileAdvertising


final class BNBidMachineAdWrapper: NSObject, Ad {
    private let _wrapped: BDMAdProtocol
    
    var wrapped: AnyObject { _wrapped }
    
    let currency: Currency = .default
    
    let networkName: String = "bidmachine"
    
    var id: String {
        _wrapped.auctionInfo.bidID ?? _wrapped.auctionInfo.description
    }
    
    var price: Price {
        _wrapped.auctionInfo.price?.doubleValue ?? .unknown
    }
    
    var dsp: String? {
        _wrapped.auctionInfo.demandSource
    }
    
    
    init(_ wrapped: BDMAdProtocol) {
        self._wrapped = wrapped
        super.init()
    }
}


final class BNEmptyBidMachineAdWrapper: NSObject, Ad {
    let wrapped: AnyObject = NSNull()
    
    let id: String = "bidmachine"
    let price: Price = .unknown
    let networkName: String = "bidmachine"
    let currency: Currency = .default
    let dsp: String? = nil
}



extension Optional where Wrapped == BDMAdProtocol {
    var wrapped: Ad {
        switch self {
        case .none:
            return BNEmptyBidMachineAdWrapper()
        case .some(let wrapped):
            return BNBidMachineAdWrapper(wrapped)
        }
    }
}
