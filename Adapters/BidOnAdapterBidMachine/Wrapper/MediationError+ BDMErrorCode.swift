//
//  MediationError.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 07.09.2022.
//

import Foundation
import BidOn
import BidMachine


extension MediationError {
    init(bdmError: Error) {
        guard
            let bdmError = bdmError as? NSError,
            let code = BDMErrorCode(rawValue: bdmError.code)
        else {
            self = .unscpecifiedException
            return
        }
        
        switch code {
        case .timeout: self = .bidTimeoutReached
        case .httpServerError: self = .networkError
        case .noContent, .badContent: self = .noBid
        default: self = .unscpecifiedException
        }
    }
}

