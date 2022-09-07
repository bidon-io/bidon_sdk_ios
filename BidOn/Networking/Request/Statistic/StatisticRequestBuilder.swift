//
//  StatisticRequestBuilder.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


final class StatisticRequestBuilder: BaseRequestBuilder {
    private(set) var stats: MediationAttemptReportModel!
    
    var adType: AdType!
    
    @discardableResult
    func withMediationReport<T: MediationAttemptReport>(_ report: T) -> Self {
        self.stats = MediationAttemptReportModel(report)
        return self
    }
    
    @discardableResult
    func withAdType(_ adType: AdType) -> Self {
        self.adType = adType
        return self
    }
}
