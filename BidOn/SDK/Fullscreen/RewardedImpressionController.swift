//
//  RewardedImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit


final class RewardedImpressionController: NSObject, FullscreenImpressionController {
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    private let provider: RewardedAdDemandProvider
    private let impression: Impression
    
    required init(demand: AnyRewardedAdDemand) {
        let demand = demand.unwrapped()
        self.provider = demand.provider
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
