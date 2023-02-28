//
//  MediationError+GADErrorCode.swift
//  BidOnAdapterGoogleMobileAds
//
//  Created by Stas Kochkin on 07.09.2022.
//

import Foundation
import BidOn
import GoogleMobileAds


extension MediationError {
    init(gadError: Error?) {
        guard
            let gadError = gadError as? NSError,
            let code = GADErrorCode(rawValue: gadError.code)
        else {
            self = .unscpecifiedException
            return
        }
        
        switch code {
        case .noFill: self = .noFill
        case .networkError: self = .networkError
        case .invalidRequest, .invalidArgument: self = .incorrectAdUnitId
        case .timeout: self = .networkError
        default: self = .unscpecifiedException
        }
    }
}
