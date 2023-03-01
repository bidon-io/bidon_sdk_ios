//
//  BidMachineBaseDemandProvider.swift
//  BidonAdapterBidMachine
//
//  Created by Bidon Team on 23.02.2023.
//

import Foundation
import UIKit
import BidMachine
import BidMachineApiCore
import Bidon


class BidMachineBaseDemandProvider<AdType: BidMachineAdProtocol>: NSObject, BidMachineAdDelegate {
    private typealias AdTypeWrapper = BidMachineAdWrapper<AdType>
    
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    var placementFormat: BidMachineApiCore.PlacementFormat {
        fatalError("Base demand provider doesn't provide placement format")
    }
    
    private var response: DemandProviderResponse?
    
    func didLoadAd(_ ad: BidMachineAdProtocol) {
        let wrapper = BidMachineAdWrapper(ad)
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
        let wrapper = BidMachineAdWrapper(ad)
        let adRevenue = BidMachineAdRevenueWrapper(ad)
        
        revenueDelegate?.provider(self, didPay: adRevenue, ad: wrapper)
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


extension BidMachineBaseDemandProvider: ProgrammaticDemandProvider {
    func bid(_ pricefloor: Price, response: @escaping DemandProviderResponse) {
        do {
            let configuration = try BidMachineSdk.shared.requestConfiguration(placementFormat)
            
            configuration.populate { builder in
                builder.appendPriceFloor(pricefloor, UUID().uuidString)
            }
            
            BidMachineSdk.shared.ad(AdType.self, configuration) { ad, error in
                guard let ad = ad, error == nil else {
                    response(.failure(.noBid))
                    return
                }
                                
                let wrapper = AdTypeWrapper(ad)
                response(.success(wrapper))
            }
        } catch {
            response(.failure(.unscpecifiedException))
        }
    }
    
    func fill(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let ad = ad as? AdTypeWrapper else {
            response(.failure(.unknownAdapter))
            return
        }
        
        self.response = response
        
        ad.wrapped.controller = UIApplication.shared.bd.topViewcontroller
        ad.wrapped.delegate = self
        ad.wrapped.loadAd()
    }
        
    func notify(ad: Ad, event: AuctionEvent) {
        guard let ad = ad as? AdTypeWrapper else { return }
        
        switch event {
        case .win:
            BidMachineSdk.shared.notifyMediationWin(ad.wrapped)
        case .lose(let winner):
            BidMachineSdk.shared.notifyMediationLoss(
                winner.networkName,
                winner.eCPM,
                ad.wrapped
            )
        }
    }
}
