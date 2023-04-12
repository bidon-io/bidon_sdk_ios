//
//  AnyBidKeeper.swift
//  Bidon
//
//  Created by Stas Kochkin on 12.04.2023.
//

import Foundation


final class BidKeeper<BidType: Bid> where BidType.Provider: DemandProvider {
    let bid: BidType
    let onExpire: (BidType) -> ()
    
    init(
        bid: BidType,
        onExpire: @escaping (BidType) -> ()
    ) {
        self.bid = bid
        self.onExpire = onExpire
        
        bid.provider.delegate = self
    }
}


extension BidKeeper: DemandProviderDelegate {
    func providerWillPresent(_ provider: any DemandProvider) {
        Logger.debug("Unexpected call of -providerWillPresent: \(provider) was received")
    }
    
    func providerDidHide(_ provider: any DemandProvider) {
        Logger.debug("Unexpected call of -providerDidHide: \(provider) was received")
    }
    
    func providerDidClick(_ provider: any DemandProvider) {
        Logger.debug("Unexpected call of -providerDidClick: \(provider) was received")
    }
    
    func provider(_ provider: any DemandProvider, didExpireAd ad: DemandAd) {
        onExpire(bid)
    }
    
    func provider(_ provider: any DemandProvider, didFailToDisplayAd ad: DemandAd, error: SdkError) {
        Logger.debug("Unexpected call of -provider:didFailToDisplayAd:error: \(provider) was received")
    }
}
