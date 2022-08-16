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
    private typealias Request = RequestWrapper<BDMInterstitialRequest>
    
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
        guard let adObject = ad.wrapped as? BDMAdProtocol else {
            response(.failure(SdkError.internalInconsistency))
            return
        }
        
        self.response = response
        interstitial.loadAd(adObject)
    }
    
    func show(ad: Ad, from viewController: UIViewController) {
        interstitial.present(fromRootViewController: viewController)
    }
}


extension BidMachineInterstitialDemandProvider: BDMInterstitialDelegate {
    func interstitialReady(toPresent interstitial: BDMInterstitial) {
        response?(.success(interstitial.adObject.wrapped))
        response = nil
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedWithError error: Error) {
        response?(.failure(error))
        response = nil
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedToPresentWithError error: Error) {
        delegate?.provider(self, didPresent: interstitial.adObject.wrapped)
    }
    
    func interstitialWillPresent(_ interstitial: BDMInterstitial) {
        delegate?.provider(self, didPresent: interstitial.adObject.wrapped)
    }
    
    func interstitialDidDismiss(_ interstitial: BDMInterstitial) {
        delegate?.provider(self, didHide: interstitial.adObject.wrapped)
    }
    
    func interstitialRecieveUserInteraction(_ interstitial: BDMInterstitial) {
        delegate?.provider(self, didClick: interstitial.adObject.wrapped)
    }
}


extension BidMachineInterstitialDemandProvider: BDMAdEventProducerDelegate {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        revenueDelegate?.provider(self, didPayRevenueFor: interstitial.adObject.wrapped)
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
}
