//
//  RewardedImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit



final class RewardedImpressionController: NSObject, FullscreenImpressionController {
    private struct RewardedImpression: Impression {
        var impressionId: String = UUID().uuidString
        
        var auctionId: String
        var auctionConfigurationId: Int
        var ad: Ad
        
        init(demand: Demand) {
            self.auctionId = demand.auctionId
            self.auctionConfigurationId = demand.auctionConfigurationId
            self.ad = demand.ad
        }
    }
    
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    private let provider: RewardedAdDemandProvider
    private let impression: Impression
    
    required init(demand: Demand) throws {
        guard let provider = demand.provider as? RewardedAdDemandProvider else {
            throw SdkError.internalInconsistency
        }
        
        self.provider = provider
        self.impression = FullscreenImpression(demand: demand)
        
        super.init()
        
        provider.delegate = self
        provider.rewardDelegate = self
    }
    
    func show(from context: UIViewController) {
        provider.show(ad: impression.ad, from: context)
    }
}


extension RewardedImpressionController: DemandProviderDelegate {
    func providerWillPresent(_ provider: DemandProvider) {
        delegate?.willPresent(impression)
    }
    
    func providerDidHide(_ provider: DemandProvider) {
        delegate?.didHide(impression)
    }
    
    func providerDidClick(_ provider: DemandProvider) {
        delegate?.didClick(impression)
    }
    
    func providerDidFailToDisplay(_ provider: DemandProvider, error: Error) {
        delegate?.didFailToPresent(impression, error: error)
    }
}


extension RewardedImpressionController: DemandProviderRewardDelegate {
    func provider(_ provider: DemandProvider, didReceiveReward reward: Reward) {
        delegate?.didReceiveReward(reward, impression: impression)
    }
}
