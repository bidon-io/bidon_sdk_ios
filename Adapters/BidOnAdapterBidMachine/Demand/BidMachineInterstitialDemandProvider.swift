//
//  BidMachineInterstitialDemandProvider.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 04.07.2022.
//

import Foundation
import BidOn
import BidMachine
import UIKit


internal final class BidMachineInterstitialDemandProvider: NSObject {
    private typealias Request = BidMachineRequestWrapper<BDMInterstitialRequest>
    
    private var response: DemandProviderResponse?
    
    private lazy var request = Request(
        request: BDMInterstitialRequest()
    )
    
    private lazy var interstitial: BDMInterstitial = {
        let interstitial = BDMInterstitial()
        interstitial.delegate = self
        interstitial.producerDelegate = self
        
        return interstitial
    }()
    
    weak var delegate: DemandProviderDelegate?
    weak var revenueDelegate: DemandProviderRevenueDelegate?
    
    override init() {
        super.init()
    }
}


extension BidMachineInterstitialDemandProvider: ProgrammaticDemandProvider {
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


extension BidMachineInterstitialDemandProvider: InterstitialDemandProvider {
    func load(ad: Ad, response: @escaping DemandProviderResponse) {
        guard let ad = ad as? BidMachineAd else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        self.response = response
        interstitial.loadAd(ad.wrapped)
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        interstitial.present(fromRootViewController: viewController)
    }
}


extension BidMachineInterstitialDemandProvider: BDMInterstitialDelegate {
    func interstitialReady(toPresent interstitial: BDMInterstitial) {
        guard let adObject = interstitial.adObject else { return }
        response?(.success(BidMachineAd(adObject)))
        response = nil
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedWithError error: Error) {
        response?(.failure(SdkError(error)))
        response = nil
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedToPresentWithError error: Error) {
        delegate?.providerDidFailToDisplay(self, error: SdkError(error))
    }
    
    func interstitialWillPresent(_ interstitial: BDMInterstitial) {
        delegate?.providerWillPresent(self)
    }
    
    func interstitialDidDismiss(_ interstitial: BDMInterstitial) {
        delegate?.providerDidHide(self)
    }
    
    func interstitialRecieveUserInteraction(_ interstitial: BDMInterstitial) {
        delegate?.providerDidClick(self)
    }
}


extension BidMachineInterstitialDemandProvider: BDMAdEventProducerDelegate {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        guard let adObject = interstitial.adObject else { return }

        revenueDelegate?.provider(self, didPayRevenueFor: BidMachineAd(adObject))
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
}
