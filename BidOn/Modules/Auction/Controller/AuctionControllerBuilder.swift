//
//  AuctionControllerBuilder.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation


public final class AuctionControllerBuilder {
    private var mediation: ConcurentAuctionRound!
    private var postbid: ConcurentAuctionRound!
    private var resolver: AuctionResolver!
    private var delegate: AuctionControllerDelegate?
    private var adType: AdType!
    
    public init() {}
    
    @discardableResult
    public func withAdType(_ adType: AdType) -> Self {
        self.adType = adType
        return self
    }

    @discardableResult
    public func withMediator(
        _ mediator: DemandProvider,
        timeout: TimeInterval = 10
    ) -> Self {
        self.mediation = ConcurentAuctionRound(
            id: "mediation",
            timeout: timeout,
            providers: [mediator]
        )
        return self
    }
    
    @discardableResult
    public func withPostbid(
        _ providers: [DemandProvider],
        timeout: TimeInterval = 5
    ) -> Self {
        self.postbid = ConcurentAuctionRound(
            id: "postbid",
            timeout: timeout,
            providers: providers
        )
        return self
    }
    
    @discardableResult
    public func withResolver(_ resolver: AuctionResolver) -> Self {
        self.resolver = resolver
        return self
    }
    
    @discardableResult
    public func withDelegate(_ delegate: AuctionControllerDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    public func build() throws -> AuctionController {
        guard
            let mediation = mediation,
            let postbid = postbid,
            let resolver = resolver
        else { throw SdkError.internalInconsistency }
        
        var auction = ConcurentAuction(rounds: [mediation, postbid])
        try auction.addEdge(from: mediation, to: postbid)
        
        return AuctionController(
            auction: auction,
            resover: resolver,
            adType: adType,
            delegate: delegate
        )
    }
}
