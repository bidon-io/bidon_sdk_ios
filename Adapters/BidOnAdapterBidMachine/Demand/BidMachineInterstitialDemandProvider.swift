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
    private var response: DemandProviderResponse?
    
    private lazy var request = BDMInterstitialRequest()
    
    private lazy var interstitial: BDMInterstitial = {
        let interstitial = BDMInterstitial()
//        interstitial.delegate = self
//        interstitial.producerDelegate = self
        
        return interstitial
    }()
    
    weak var delegate: DemandProviderDelegate?
    
    override init() {
        super.init()
    }
}

//
//extension BidMachineInterstitialDemandProvider: InterstitialDemandProvider {
//    func request(
//        pricefloor: Price,
//        response: @escaping DemandProviderResponse
//    ) {
//        self.response = response
//        let request = BDMInterstitialRequest()
//        request.type = .fullscreenAdTypeAll
//        request.priceFloors = [pricefloor.bdm]
//        interstitial.populate(with: request)
//    }
//
//    func show(ad: Ad, from viewController: UIViewController) {
//        interstitial.present(fromRootViewController: viewController)
//    }
//
//    func notify(_ event: AuctionEvent) {
//        switch (event) {
//        case .win:
//            request.notifyMediationWin()
//        case .lose(let ad):
//            request.notifyMediationLoss(ad.dsp, ecpm: ad.price as NSNumber)
//        }
//    }
//
//    func cancel() {
//        response?(nil, SdkError.cancelled)
//        response = nil
//    }
//}
//
//
//extension BidMachineInterstitialDemandProvider: BDMInterstitialDelegate {
//    func interstitialReady(toPresent interstitial: BDMInterstitial) {
//        response?(interstitial.adObject.wrapped, nil)
//        response = nil
//    }
//
//    func interstitial(_ interstitial: BDMInterstitial, failedWithError error: Error) {
//        response?(nil, error)
//        response = nil
//    }
//
//    func interstitial(_ interstitial: BDMInterstitial, failedToPresentWithError error: Error) {
//        delegate?.provider(self, didPresent: interstitial.adObject.wrapped)
//    }
//
//    func interstitialWillPresent(_ interstitial: BDMInterstitial) {
//        delegate?.provider(self, didPresent: interstitial.adObject.wrapped)
//    }
//
//    func interstitialDidDismiss(_ interstitial: BDMInterstitial) {
//        delegate?.provider(self, didHide: interstitial.adObject.wrapped)
//    }
//
//    func interstitialRecieveUserInteraction(_ interstitial: BDMInterstitial) {
//        delegate?.provider(self, didClick: interstitial.adObject.wrapped)
//    }
//}
//
//
//extension BidMachineInterstitialDemandProvider: BDMAdEventProducerDelegate {
//    func didProduceImpression(_ producer: BDMAdEventProducer) {
//        delegate?.provider(self, didPayRevenueFor: interstitial.adObject.wrapped)
//    }
//
//    func didProduceUserAction(_ producer: BDMAdEventProducer) {}
//}
