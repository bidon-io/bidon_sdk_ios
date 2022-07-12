//
//  InterstitialRouter.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class BNISInterstitialRouter: NSObject {
    let mediator = IronSourceInterstitialDemandProvider()
    
    weak var delegate: ISInterstitialDelegate?
    weak var levelPlayDelegate: LevelPlayInterstitialDelegate?
    
    private var postbid: [InterstitialDemandProvider] {
        IronSource.bid.bidon.interstitialDemandProviders()
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
            IronSourceInterstitialDemandProvider.DisplayArguments(
                placement: placement,
                instanceId: instance
            )
        }
        
        auction.finish { [weak self] provider, ad, error in
            guard let ad = ad else { return }
            guard let provider = provider as? InterstitialDemandProvider else {
                self?.delegate?.interstitialDidFailToShowWithError(SDKError(error))
                return
            }
            
            provider.delegate = self
            provider._show(ad: ad, from: viewController)
        }
    }
}


extension BNISInterstitialRouter: AuctionControllerDelegate {
    func controllerDidStartAuction(_ controller: AuctionController) {
        
    }
    
    func controller(_ contoller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        
    }
    
    func controller(_ contoller: AuctionController, didCompleteRound round: AuctionRound) {
        
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        
    }
}


extension BNISInterstitialRouter: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        
    }
}
