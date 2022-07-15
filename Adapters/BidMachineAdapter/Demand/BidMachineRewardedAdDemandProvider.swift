//
//  BidMachineRewardedAdDemandProvider.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import MobileAdvertising
import BidMachine
import UIKit


internal final class BidMachineRewardedAdDemandProvider: NSObject {
    private var response: DemandProviderResponse?
    
    private lazy var request = BDMRewardedRequest()
    
    private lazy var rewardedAd: BDMRewarded = {
        let rewardedAd = BDMRewarded()
        rewardedAd.delegate = self
        return rewardedAd
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    override init() {
        super.init()
    }
}


extension BidMachineRewardedAdDemandProvider: RewardedAdDemandProvider {
    func request(
        pricefloor: Price,
        response: @escaping DemandProviderResponse
    ) {
        self.response = response
        request.priceFloors = [pricefloor.bdm]
        rewardedAd.populate(with: request)
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        rewardedAd.present(fromRootViewController: viewController)
    }
    
    func notify(_ event: AuctionEvent) {
        switch (event) {
        case .win:
            request.notifyMediationWin()
        case .lose(let ad):
            request.notifyMediationLoss(ad.dsp, ecpm: ad.price as NSNumber)
        }
    }
    
    func cancel() {
        response?(nil, SDKError.cancelled)
        response = nil
    }
}

 
extension BidMachineRewardedAdDemandProvider: BDMRewardedDelegate {
    func rewardedReady(toPresent rewarded: BDMRewarded) {
        response?(rewarded.adObject.wrapped, nil)
        response = nil
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedWithError error: Error) {
        response?(nil, error)
        response = nil
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedToPresentWithError error: Error) {
        delegate?.provider(self, didPresent: rewarded.adObject.wrapped)
    }
    
    func rewardedWillPresent(_ rewarded: BDMRewarded) {
        delegate?.provider(self, didPresent: rewarded.adObject.wrapped)
    }
    
    func rewardedDidDismiss(_ rewarded: BDMRewarded) {
        delegate?.provider(self, didHide: rewarded.adObject.wrapped)
    }
    
    func rewardedRecieveUserInteraction(_ rewarded: BDMRewarded) {
        delegate?.provider(self, didClick: rewarded.adObject.wrapped)
    }
    
    func rewardedFinishRewardAction(_ rewarded: BDMRewarded) {
        rewardDelegate?.provider(self, didReceiveReward: EmptyReward(), ad: rewarded.adObject.wrapped)
    }
    
    func rewardedDidExpire(_ rewarded: BDMRewarded) {}
}
