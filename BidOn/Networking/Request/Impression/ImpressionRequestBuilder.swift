//
//  ImpressionRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class ImpressionRequestBuilder: BaseRequestBuilder {
    private(set) var imp: ImpressionModel!
    
    @discardableResult
    func withImpression(_ impression: Impression) -> Self {
        self.imp = ImpressionModel(impression)
        return self
    }
}
