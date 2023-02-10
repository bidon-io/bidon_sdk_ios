//
//  BidMachineRewardedAdDemandProvider.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidOn


final class BidMachineRewardedAdDemandProvider: NSObject, RewardedAdDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    weak var rewardDelegate: DemandProviderRewardDelegate?
    
    private var response: DemandProviderResponse?
    
    private var rewardedAd: BidMachineRewarded? {
        didSet {
            rewardedAd?.delegate = self
            rewardedAd?.controller = UIApplication.shared.bd.topViewcontroller
        }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let rewardedAd = rewardedAd, rewardedAd.auctionInfo.bidId == ad.id else {
            response(.failure(.unknownAdapter))
            return
        }
        
        self.response = response
        rewardedAd.loadAd()
    }
    
    func cancel(_ reason: DemandProviderCancellationReason) {}
    
    func notify(_ event: AuctionEvent) {
        guard let rewardedAd = rewardedAd else { return }
        switch event {
        case .win(let ad):
            if rewardedAd.auctionInfo.bidId == ad.id {
                BidMachineSdk.shared.notifyMediationWin(rewardedAd)
            }
        case .lose(let ad):
            BidMachineSdk.shared.notifyMediationLoss(
                ad.networkName,
                ad.price,
                rewardedAd
            )
        }
    }
    
    func show(
        ad: Ad,
        from viewController: UIViewController
    ) {
        guard
            let rewardedAd = rewardedAd,
            rewardedAd.auctionInfo.bidId == ad.id,
            rewardedAd.canShow
        else {
            delegate?.providerDidFailToDisplay(self, error: .invalidPresentationState)
            return
        }
        
        rewardedAd.controller = viewController
        rewardedAd.presentAd()
    }
}


extension BidMachineRewardedAdDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        do {
            let configuration = try BidMachineSdk.shared.requestConfiguration(.rewarded)
            configuration.populate { builder in
                builder.appendPriceFloor(pricefloor, UUID().uuidString)
            }
            
            BidMachineSdk.shared.rewarded { [weak self] rewardedAd, error in
                guard let rewardedAd = rewardedAd, error == nil else {
                    response(.failure(.noBid))
                    return
                }
                
                self?.rewardedAd = rewardedAd
                
                let wrapper = AuctionResponseWrapper(rewardedAd.auctionInfo)
                response(.success(wrapper))
            }
        } catch {
            response(.failure(.unscpecifiedException))
        }
    }
}


extension BidMachineRewardedAdDemandProvider: BidMachineAdDelegate {
    func didLoadAd(_ ad: BidMachineAdProtocol) {
        let wrapper = AuctionResponseWrapper(ad.auctionInfo)
        response?(.success(wrapper))
        response = nil
    }
    
    func didFailLoadAd(_ ad: BidMachineAdProtocol, _ error: Error) {
        response?(.failure(.noFill))
    }
    
    func didPresentAd(_ ad: BidMachineAdProtocol) {
        delegate?.providerWillPresent(self)
    }
    
    func didTrackImpression(_ ad: BidMachineAdProtocol) {
        let wrapper = AuctionResponseWrapper(ad.auctionInfo)
        revenueDelegate?.provider(self, didPayRevenueFor: wrapper)
    }
    
    func didFailPresentAd(_ ad: BidMachineAdProtocol, _ error: Error) {
        delegate?.providerDidFailToDisplay(self, error: .generic(error: error))
    }
    
    func didDismissAd(_ ad: BidMachineAdProtocol) {
        rewardDelegate?.provider(self, didReceiveReward: EmptyReward())
        delegate?.providerDidHide(self)
    }
    
    func didUserInteraction(_ ad: BidMachineAdProtocol) {
        delegate?.providerDidClick(self)
    }
    
    // Noop
    func willPresentScreen(_ ad: BidMachineAdProtocol) {}
    func didDismissScreen(_ ad: BidMachineAdProtocol) {}
    func didExpired(_ ad: BidMachineAdProtocol) {}
    func didTrackInteraction(_ ad: BidMachineAdProtocol) {}
}
