//
//  BidMachineInterstitialDemandProvider.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidOn


final class BidMachineInterstitialDemandProvider: NSObject, InterstitialDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    private var response: DemandProviderResponse?
    
    private var interstitial: BidMachineInterstitial? {
        didSet {
            interstitial?.delegate = self
            interstitial?.controller = UIApplication.shared.bd.topViewcontroller
        }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let interstitial = interstitial, interstitial.auctionInfo.bidId == ad.id else {
            response(.failure(.unknownAdapter))
            return
        }
        
        self.response = response
        interstitial.loadAd()
    }
    
    func cancel(_ reason: DemandProviderCancellationReason) {}
    
    func notify(_ event: AuctionEvent) {
        guard let interstitial = interstitial else { return }
        switch event {
        case .win(let ad):
            if interstitial.auctionInfo.bidId == ad.id {
                BidMachineSdk.shared.notifyMediationWin(interstitial)
            }
        case .lose(let ad):
            BidMachineSdk.shared.notifyMediationLoss(
                ad.networkName,
                ad.price,
                interstitial
            )
        }
    }
    
    func show(
        ad: Ad,
        from viewController: UIViewController
    ) {
        guard
            let interstitial = interstitial,
            interstitial.auctionInfo.bidId == ad.id,
            interstitial.canShow
        else {
            delegate?.providerDidFailToDisplay(self, error: .invalidPresentationState)
            return
        }
        
        interstitial.controller = viewController
        interstitial.presentAd()
    }
}


extension BidMachineInterstitialDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        do {
            let configuration = try BidMachineSdk.shared.requestConfiguration(.interstitial)
            configuration.populate { builder in
                builder.appendPriceFloor(pricefloor, UUID().uuidString)
            }
            
            BidMachineSdk.shared.interstitial(configuration) { [weak self] interstitial, error in
                guard let interstitial = interstitial, error == nil else {
                    response(.failure(.noBid))
                    return
                }
                
                self?.interstitial = interstitial
                
                let wrapper = AuctionResponseWrapper(interstitial.auctionInfo)
                response(.success(wrapper))
            }
        } catch {
            response(.failure(.unscpecifiedException))
        }
    }
}


extension BidMachineInterstitialDemandProvider: BidMachineAdDelegate {
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
