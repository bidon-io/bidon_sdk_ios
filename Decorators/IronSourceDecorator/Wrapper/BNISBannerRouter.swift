//
//  BNISBannerRouter.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import IronSource
import MobileAdvertising


final class BNISBannerRouter: NSObject {
    let mediator = IronSourceAdViewDemandProvider()
    
    weak var delegate: BNISBannerDelegate?
    weak var levelPlayDelegate: BNLevelPlayBannerDelegate?
    weak var auctionDelegate: BNISAuctionDelegate?
    
    var resolver: AuctionResolver = HigherRevenueAuctionResolver()
    
    private var postbid: [AdViewDemandProvider] {
        IronSource.bid.bidon.adViewDemandProviders(.init(.banner))
    }
    
    var auction: AuctionController!
    
    override init() {
        super.init()
        
        weak var weakSelf = self
        mediator.load = weakSelf?.loadAd
    }
    
    func loadAd() {
        auction = try! AuctionControllerBuilder()
            .withMediator(mediator)
            .withPostbid(postbid)
            .withResolver(resolver)
            .withDelegate(self)
            .build()
        
        auction.load()
    }
    
    func finish() {
        guard let auction = auction else { return }
        auction.finish { [weak self] provider, ad, error in
            guard
                let self = self,
                let provider = provider as? AdViewDemandProvider,
                let ad = ad,
                let view = provider.adView(for: ad)
            else {
                let wrapped = error.map { SDKError($0) } ?? .unknown
                self?.delegate?.bannerDidFailToLoadWithError(wrapped)
                self?.levelPlayDelegate?.didFailToLoadWithError(wrapped)
                return
            }
            
            self.delegate?.bannerDidLoad(view)
            self.levelPlayDelegate?.didLoad(view, with: ad)
        }
    }
    
    func destroy(_ view: UIView) {
        (view as? ISBannerView).map { IronSource.destroyBanner($0) }
    }
}


extension BNISBannerRouter: AuctionControllerDelegate {
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
        finish()
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        delegate?.bannerDidFailToLoadWithError(error)
        levelPlayDelegate?.didFailToLoadWithError(error)
    }
}


extension BNISBannerRouter: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.didClickBanner()
        levelPlayDelegate?.didClick(with: ad)
    }
    
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {}
    func provider(_ provider: DemandProvider, didHide ad: Ad) {}
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {}
}


extension BNISBannerRouter: DemandProviderAdViewDelegate {
    func provider(_ provider: AdViewDemandProvider, willLeaveApplication ad: Ad) {
        delegate?.bannerWillLeaveApplication()
        levelPlayDelegate?.didLeaveApplication(with: ad)
    }
    
    func provider(_ provider: AdViewDemandProvider, willPresentModalView ad: Ad) {
        delegate?.bannerWillPresentScreen()
        levelPlayDelegate?.didPresentScreen(with: ad)
    }
    
    func provider(_ provider: AdViewDemandProvider, didDismissModalView ad: Ad) {
        delegate?.bannerDidDismissScreen()
        levelPlayDelegate?.didDismissScreen(with: ad)
    }
}
