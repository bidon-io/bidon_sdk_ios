//
//  BidMachineRewardedAdDemandProvider.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import BidOn
import BidMachine
import UIKit


internal final class BidMachineRewardedAdDemandProvider: NSObject {
    private typealias Request = BidMachineRequestWrapper<BDMRewardedRequest>
    
    private var response: DemandProviderResponse?
    
    private lazy var request = Request(
        request: BDMRewardedRequest()
    )
    
    private lazy var rewardedAd: BDMRewarded = {
        let rewardedAd = BDMRewarded()
        rewardedAd.delegate = self
        rewardedAd.producerDelegate = self
        return rewardedAd
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    override init() {
        super.init()
    }
}


extension BidMachineRewardedAdDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        request.bid(pricefloor, response: response)
    }
    
    func notify(_ event: AuctionEvent) {
        request.notify(event)
    }
    
    func cancel() {
        request.cancel()
    }
}


extension BidMachineRewardedAdDemandProvider: RewardedAdDemandProvider {
    func load(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let ad = ad as? BidMachineAd else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        self.response = response
        rewardedAd.loadAd(ad.wrapped)
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        rewardedAd.present(fromRootViewController: viewController)
    }
}


extension BidMachineRewardedAdDemandProvider: BDMRewardedDelegate {
    func rewardedReady(toPresent rewarded: BDMRewarded) {
        guard let adObject = rewarded.adObject else { return }
        
        response?(.success(BidMachineAd(adObject)))
        response = nil
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedWithError error: Error) {
        response?(.failure(error))
        response = nil
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedToPresentWithError error: Error) {
        delegate?.providerDidFailToDisplay(self, error: error)
    }
    
    func rewardedWillPresent(_ rewarded: BDMRewarded) {
        delegate?.providerWillPresent(self)
    }
    
    func rewardedDidDismiss(_ rewarded: BDMRewarded) {
        delegate?.providerDidHide(self)
    }
    
    func rewardedRecieveUserInteraction(_ rewarded: BDMRewarded) {
        delegate?.providerDidClick(self)
    }
    
    func rewardedFinishRewardAction(_ rewarded: BDMRewarded) {
        rewardDelegate?.provider(self, didReceiveReward: EmptyReward())
    }
    
    func rewardedDidExpire(_ rewarded: BDMRewarded) {}
}


extension BidMachineRewardedAdDemandProvider: BDMAdEventProducerDelegate {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        guard let adObject = rewardedAd.adObject else { return }
        
        revenueDelegate?.provider(self, didPayRevenueFor: BidMachineAd(adObject))
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
}
