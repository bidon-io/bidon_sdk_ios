//
//  StatisticRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class StatisticRequestBuilder: BaseRequestBuilder {
    private(set) var stats: MediationResultModel!
    
    @discardableResult
    func withMediationResult<T: MediationResult>(_ result: T) -> Self {
        self.stats = MediationResultModel(result)
        return self
    }
}
