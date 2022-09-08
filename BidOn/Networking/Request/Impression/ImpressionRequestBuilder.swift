//
//  ImpressionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class ImpressionRequestBuilder: BaseRequestBuilder {
    private(set) var imp: ImpressionModel!
    private(set) var adType: AdType!
    
    @discardableResult
    func withImpression(_ impression: Impression) -> Self {
        self.imp = ImpressionModel(impression)
        return self
    }
    
    @discardableResult
    func withAdType(_ adType: AdType) -> Self {
        self.adType = adType
        return self
    }
}
