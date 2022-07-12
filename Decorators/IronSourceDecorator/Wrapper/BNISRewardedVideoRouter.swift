//
//  RewardedVideoRouter.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class BNISRewardedVideoRouter: NSObject {
    let mediator = IronSourceRewardedAdDemandProvider()
    
    weak var delegate: ISRewardedVideoDelegate?
    weak var levelPlayDelegate: LevelPlayRewardedVideoDelegate?
    
    private var postbid: [RewardedAdDemandProvider] {
        IronSource.bid.bidon.rewardedAdDemandProviders()
    }
    
    lazy var auction = try! AuctionControllerBuilder()
        .withMediator(mediator)
        .withPostbid(postbid)
        .withResolver(HigherRevenueAuctionResolver())
        .withDelegate(self)
        .build()
    
    override init() {
        super.init()
        
        weak var weakSelf = self
        mediator.load = weakSelf?.auction.load
    }
    
    func show(
        from viewController: UIViewController,
        placement: String? = nil,
        instance: String? = nil
    ) {
        mediator.displayArguments = {
            IronSourceRewardedAdDemandProvider.DisplayArguments(
                placement: placement,
                instanceId: instance
            )
        }
        
        auction.finish { [weak self] provider, ad, error in
            guard let ad = ad else { return }
            guard let provider = provider as? RewardedAdDemandProvider else {
                self?.delegate?.rewardedVideoDidFailToShowWithError(SDKError(error))
                return
            }
            
            provider.delegate = self
            provider.rewardDelegate = self
            
            provider._show(ad: ad, from: viewController)
        }
    }
}


extension BNISRewardedVideoRouter: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {
       
    }
    
    func controller(_ contoller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        
    }
    
    func controller(_ contoller: AuctionController, didCompleteRound round: AuctionRound) {
        
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        delegate?.rewardedVideoHasChangedAvailability(true)
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        delegate?.rewardedVideoHasChangedAvailability(false)
    }
}


extension BNISRewardedVideoRouter: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.rewardedVideoHasChangedAvailability(false)
        delegate?.rewardedVideoDidOpen()
        delegate?.rewardedVideoDidStart()
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.rewardedVideoDidEnd()
        delegate?.rewardedVideoDidClose()
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        let placement = ISPlacementInfo(
            placement: "",
            reward: "",
            rewardAmount: 0
        )
        
        delegate?.didClickRewardedVideo(placement)
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.rewardedVideoHasChangedAvailability(false)
        delegate?.rewardedVideoDidFailToShowWithError(error)
    }
}


extension BNISRewardedVideoRouter: DemandProviderRewardDelegate {
    func provider(_ provider: DemandProvider, didReceiveReward reward: Reward, ad: Ad) {
        let placement = ISPlacementInfo(
            placement: "",
            reward: reward.label,
            rewardAmount: reward.amount as NSNumber
        )
        
        delegate?.didReceiveReward(forPlacement: placement)
    }
}
