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
    weak var levelPlayDelegate: BNLevelPlayInterstitialDelegate?
    weak var auctionDelegate: BNISAuctionDelegate?

    var resolver: AuctionResolver = HigherRevenueAuctionResolver()
    var auction: AuctionController!

    private var postbid: [InterstitialDemandProvider] {
        IronSource.bid.bidon.interstitialDemandProviders()
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
            .withAdType(.interstitial)
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
            delegate?.interstitialDidFailToShowWithError(SDKError("No ad for show"))
            levelPlayDelegate?.didFailToShowWithError(SDKError("No ad for show"), andAdInfo: nil)
            return
        }
        
        mediator.displayArguments = {
            IronSourceInterstitialDemandProvider.DisplayArguments(
                placement: placement
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
        delegate?.interstitialDidLoad()
        levelPlayDelegate?.didLoad(with: winner)
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        guard controller.isEmpty else { return }
        delegate?.interstitialDidFailToLoadWithError(error)
        levelPlayDelegate?.didFailToLoadWithError(error)

    }
}


extension BNISInterstitialRouter: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.interstitialDidOpen()
        delegate?.interstitialDidShow()
        levelPlayDelegate?.didOpen(with: ad)
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.interstitialDidClose()
        levelPlayDelegate?.didClose(with: ad)
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.didClickInterstitial()
        levelPlayDelegate?.didClick(with: ad)
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.interstitialDidFailToShowWithError(error)
        levelPlayDelegate?.didFailToShowWithError(error, andAdInfo: ad)
    }
    
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        IronSource.bid.trackAdRevenue(
            ad,
            round: auction.auctionRound(for: ad),
            adType: .interstitial
        )
    }
}
