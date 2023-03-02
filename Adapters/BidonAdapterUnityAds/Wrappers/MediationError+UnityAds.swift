//
//  MediationError+UnityAdsLoadError.swift
//  BidonAdapterUnityAds
//
//  Created by Bidon Team on 02.03.2023.
//

import Foundation
import UnityAds
import Bidon


extension MediationError {
    init(_ error: UnityAdsLoadError) {
        switch error {
        case .noFill: self = .noBid
        case .invalidArgument: self = .incorrectAdUnitId
        case .initializeFailed: self = .adapterNotInitialized
        default: self = .unknownAdapter
        }
    }
    
    init(_ error: UADSBannerError?) {
        guard
            let error = error,
            let code = UADSBannerErrorCode(rawValue: error.code)
        else {
            self = .noBid
            return
        }
        
        switch code {
        case .noFillError: self = .noBid
        case .webViewError: self = .networkError
        default: self = .unscpecifiedException
        }
        
    }
}

