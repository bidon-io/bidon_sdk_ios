//
//  RewardedVideoRouter.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 11.07.2022.
//

import Foundation
import IronSource
import BidOn


final class BNISRewardedVideoRouter: NSObject {
    let mediator = IronSourceRewardedAdDemandProvider()
    
    weak var delegate: ISRewardedVideoDelegate?
    weak var levelPlayDelegate: BNLevelPlayRewardedVideoDelegate?
    weak var auctionDelegate: BNISAuctionDelegate?
    
    var resolver: AuctionResolver = HigherRevenueAuctionResolver()
    var auction: AuctionController!

    private var postbid: [RewardedAdDemandProvider] {
        IronSource.bid.bidon.rewardedAdDemandProviders()
    }
    
    var isAvailable: Bool {
        return auction.map { !$0.isEmpty } ?? false
    }
    
    override init() {
        super.init()
        
        weak var weakSelf = self
        mediator.load = weakSelf?.loadAd
    }
    
    func loadAd() {
        auction = try! AuctionControllerBuilder()
            .withAdType(.rewarded)
            .withMediator(mediator)
            .withPostbid(postbid)
            .withResolver(resolver)
            .withDelegate(self)
            .build()
        
        auction.load()
    }
    
    func show(
        from viewController: UIViewController,
        placement: String? = nil
    ) {
        guard let auction = auction else {
            delegate?.rewardedVideoDidFailToShowWithError(SDKError("No ad for show"))
            levelPlayDelegate?.didFailToShowWithError(SDKError("No ad for show"), andAdInfo: nil)
            return
        }
        
        mediator.displayArguments = {
            IronSourceRewardedAdDemandProvider.DisplayArguments(
                placement: placement
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
        auctionDelegate?.didStartAuction()
    }
    
    func controller(_ contoller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        auctionDelegate?.didStartAuctionRound(round.id, pricefloor: pricefloor)
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        auctionDelegate?.didReceiveAd(ad)
    }
    
    func controller(_ contoller: AuctionController, didCompleteRound round: AuctionRound) {
        auctionDelegate?.didCompleteAuctionRound(round.id)
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        auctionDelegate?.didCompleteAuction(winner)
        delegate?.rewardedVideoHasChangedAvailability(true)
        levelPlayDelegate?.hasAvailableAd(with: winner)
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        guard controller.isEmpty else { return }
        delegate?.rewardedVideoHasChangedAvailability(false)
        levelPlayDelegate?.hasNoAvailableAd()
    }
}


extension BNISRewardedVideoRouter: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.rewardedVideoHasChangedAvailability(false)
        delegate?.rewardedVideoDidOpen()
        delegate?.rewardedVideoDidStart()
        levelPlayDelegate?.didOpen(with: ad)
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.rewardedVideoDidEnd()
        delegate?.rewardedVideoDidClose()
        levelPlayDelegate?.didClose(with: ad)
        
        if !(ad.wrapped is ISAdInfo) {
            loadAd()
        }
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.didClickRewardedVideo(.empty())
        levelPlayDelegate?.didClick(.empty(), with: ad)
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.rewardedVideoHasChangedAvailability(false)
        delegate?.rewardedVideoDidFailToShowWithError(error)
        levelPlayDelegate?.didFailToShowWithError(error, andAdInfo: ad)
    }
    
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        IronSource.bid.trackAdRevenue(
            ad,
            round: auction.auctionRound(for: ad),
            adType: .rewarded
        )
    }
}


extension BNISRewardedVideoRouter: DemandProviderRewardDelegate {
    func provider(_ provider: DemandProvider, didReceiveReward reward: Reward, ad: Ad) {
        let placement = ISPlacementInfo.unwrapped(reward)
        delegate?.didReceiveReward(forPlacement: placement)
        levelPlayDelegate?.didReceiveReward(forPlacement: placement, with: ad)
    }
}
