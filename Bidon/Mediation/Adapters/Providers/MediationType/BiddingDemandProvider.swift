//
//  BiddingDemandProvider.swift
//  Bidon
//
//  Created by Stas Kochkin on 31.05.2023.
//

import Foundation


public protocol BiddingContextEncoder {
    func encodeBiddingContext(to encoder: Encoder) throws
}


public typealias BiddingContextResponse = (Result<BiddingContextEncoder, MediationError>) -> ()


public protocol BiddingDemandProvider: DemandProvider {
    func fetchBiddingContext(response: @escaping BiddingContextResponse)
}


final class BiddingDemandProviderWrapper<W>: DemandProviderWrapper<W>, BiddingDemandProvider {
    private let _fetchBiddingContext: (@escaping BiddingContextResponse) -> ()
    
    override init(_ wrapped: W) throws {
        guard let _wrapped = wrapped as? (any BiddingDemandProvider) else { throw SdkError.internalInconsistency }
        
        _fetchBiddingContext = { _wrapped.fetchBiddingContext(response: $0) }
        
        try super.init(wrapped)
    }
    
    func fetchBiddingContext(response: @escaping BiddingContextResponse) {
        _fetchBiddingContext(response)
    }
}
