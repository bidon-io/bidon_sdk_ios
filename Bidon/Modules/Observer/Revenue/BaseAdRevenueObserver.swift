//
//  BaseAdRevenueObserver.swift
//  Bidon
//
//  Created by Stas Kochkin on 30.03.2023.
//

import Foundation


final class BaseAdRevenueObserver: AdRevenueObserver {
    var onRegisterAdRevenue: RegisterAdRevenue?
    
    private let cache = NSMapTable<DemandAd, AdContainer>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    
    func observe<BidType>(_ bid: BidType)
    where BidType : Bid, BidType.Provider : DemandProvider {
        bid.provider.revenueDelegate = self
        
        let ad = AdContainer(bid: bid)
        cache.setObject(ad, forKey: bid.ad)
    }
}


extension BaseAdRevenueObserver: DemandProviderRevenueDelegate {
    func provider(
        _ provider: any DemandProvider,
        didPayRevenue revenue: AdRevenue,
        ad: DemandAd
    ) {
        guard let container = cache.object(forKey: ad) else { return }
        
        onRegisterAdRevenue?(container, revenue)
    }
    
    func provider(
        _ provider: any DemandProvider,
        didLogImpression ad: DemandAd
    ) {
        guard let container = cache.object(forKey: ad) else { return }
        
        let adRevenue = AdRevenueModel(eCPM: container.eCPM)
        onRegisterAdRevenue?(container, adRevenue)
    }
}
