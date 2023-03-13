//
//  RewardedImpressionController.swift
//  Bidon
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import UIKit


final class RewardedImpressionController: NSObject, FullscreenImpressionController {
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    private let provider: any RewardedAdDemandProvider
    private var impression: Impression!
    
    required init(demand: AnyRewardedAdDemand) {
        let demand = demand.unwrapped()
        self.provider = demand.provider
        self.impression = FullscreenImpression(demand: demand)
        
        super.init()
        
        provider.delegate = self
        provider.rewardDelegate = self
    }
    
    func show(from context: UIViewController) {
        provider._show(ad: impression.ad, from: context)
    }
}


extension RewardedImpressionController: DemandProviderDelegate {
    func providerWillPresent(_ provider: any DemandProvider) {
        delegate?.willPresent(&impression)
    }
    
    func providerDidHide(_ provider: any DemandProvider) {
        delegate?.didHide(&impression)
    }
    
    func providerDidClick(_ provider: any DemandProvider) {
        delegate?.didClick(&impression)
    }
    
    func providerDidFailToDisplay(_ provider: any DemandProvider, error: SdkError) {
        delegate?.didFailToPresent(&impression, error: error)
    }
}


extension RewardedImpressionController: DemandProviderRewardDelegate {
    func provider(_ provider: any DemandProvider, didReceiveReward reward: Reward) {
        delegate?.didReceiveReward(reward, impression: &impression)
    }
}
