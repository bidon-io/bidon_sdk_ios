//
//  RewardedImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit



class RewardedImpressionController: NSObject, FullscreenImpressionController {
    typealias Context = UIViewController
    
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    let provider: RewardedAdDemandProvider
    let ad: Ad
    
    required init(demand: Demand) throws {
        guard let provider = demand.provider as? RewardedAdDemandProvider else {
            throw SdkError.internalInconsistency
        }
        
        self.provider = provider
        self.ad = demand.ad
        
        super.init()
        
        provider.delegate = self
        provider.rewardDelegate = self
    }
    
    func show(from context: UIViewController) {
        provider.show(ad: ad, from: context)
    }
}


extension RewardedImpressionController: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.didPresent(ad)
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.didHide(ad)
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.didClick(ad)
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.didFailToPresent(ad, error: error)
    }
}


extension RewardedImpressionController: DemandProviderRewardDelegate {
    func provider(_ provider: DemandProvider, didReceiveReward reward: Reward, ad: Ad) {
        delegate?.didReceiveReward(reward, ad: ad)
    }
}
