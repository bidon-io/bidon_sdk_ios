//
//  BidMachineAdViewDemandSourceAdapter.swift
//  BidOnAdapterBidMachine
//
//  Created by Stas Kochkin on 10.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidOn


final class BidMachineAdViewDemandProvider: NSObject, AdViewDemandProvider {
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    weak var adViewDelegate: DemandProviderAdViewDelegate?
    
    private var response: DemandProviderResponse?
    
    private var adView: BidMachineBanner? {
        didSet {
            adView?.delegate = self
            adView?.controller = UIApplication.shared.bd.topViewcontroller
        }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let adView = adView, adView.auctionInfo.bidId == ad.id else {
            response(.failure(.unknownAdapter))
            return
        }
        
        self.response = response
        adView.loadAd()
    }
    
    func cancel(_ reason: DemandProviderCancellationReason) {}
    
    func notify(_ event: AuctionEvent) {
        guard let adView = adView else { return }
        switch event {
        case .win(let ad):
            if adView.auctionInfo.bidId == ad.id {
                BidMachineSdk.shared.notifyMediationWin(adView)
            }
        case .lose(let ad):
            BidMachineSdk.shared.notifyMediationLoss(
                ad.networkName,
                ad.price,
                adView
            )
        }
    }
    
    func container(for ad: Ad) -> AdViewContainer? {
        return adView
    }
}


extension BidMachineAdViewDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        do {
            let configuration = try BidMachineSdk.shared.requestConfiguration(.banner)
            configuration.populate { builder in
                builder.appendPriceFloor(pricefloor, UUID().uuidString)
            }
            
            BidMachineSdk.shared.banner { [weak self] adView, error in
                guard let adView = adView, error == nil else {
                    response(.failure(.noBid))
                    return
                }
                
                self?.adView = adView
                
                let wrapper = AuctionResponseWrapper(adView.auctionInfo)
                response(.success(wrapper))
            }
        } catch {
            response(.failure(.unscpecifiedException))
        }
    }
}


extension BidMachineAdViewDemandProvider: BidMachineAdDelegate {
    func didLoadAd(_ ad: BidMachineAdProtocol) {
        let wrapper = AuctionResponseWrapper(ad.auctionInfo)
        response?(.success(wrapper))
        response = nil
    }
    
    func didFailLoadAd(_ ad: BidMachineAdProtocol, _ error: Error) {
        response?(.failure(.noFill))
    }
    
    func didTrackImpression(_ ad: BidMachineAdProtocol) {
        let wrapper = AuctionResponseWrapper(ad.auctionInfo)
        revenueDelegate?.provider(self, didPayRevenueFor: wrapper)
    }
    
    func didUserInteraction(_ ad: BidMachineAdProtocol) {
        delegate?.providerDidClick(self)
    }
    
    // Noop
    func didFailPresentAd(_ ad: BidMachineAdProtocol, _ error: Error) {}
    func didPresentAd(_ ad: BidMachine.BidMachineAdProtocol) {}
    func didDismissAd(_ ad: BidMachineAdProtocol) {}
    func willPresentScreen(_ ad: BidMachineAdProtocol) {}
    func didDismissScreen(_ ad: BidMachineAdProtocol) {}
    func didExpired(_ ad: BidMachineAdProtocol) {}
    func didTrackInteraction(_ ad: BidMachineAdProtocol) {}
}


extension BidMachineBanner: AdViewContainer {
    public var isAdaptive: Bool { false }
}
