//
//  BNISBannerRouter.swift
//  IronSourceDecorator
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import IronSource
import BidOn


final class BNISBannerRouter: NSObject {
    let mediator = IronSourceAdViewDemandProvider()
    
    weak var delegate: BNISBannerDelegate?
    weak var levelPlayDelegate: BNLevelPlayBannerDelegate?
    weak var auctionDelegate: BNISAuctionDelegate?
    
    var resolver: AuctionResolver = HigherRevenueAuctionResolver()
    
    private var postbid: [AdViewDemandProvider] {
        IronSource.bn.bidon.adViewDemandProviders(context)
    }
    
    var auction: AuctionController!
    
    private var context = AdViewContext(.banner)
    
    override init() {
        super.init()
        
        weak var weakSelf = self
        mediator.load = weakSelf?.performAuction
    }
    
    func performAuction() {
        auction = try! AuctionControllerBuilder()
            .withAdType(.banner)
            .withMediator(mediator)
            .withPostbid(postbid)
            .withResolver(resolver)
            .withDelegate(self)
            .build()
        
        auction.load()
    }
    
    func loadBanner(
        with rootViewController: UIViewController,
        size: ISBannerSize
    ) {
        context = AdViewContext(
            size.format,
            isAdaptive: size.isAdaptive,
            rootViewController: rootViewController
        )
        
        IronSource.loadBanner(with: rootViewController, size: size)
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
                let wrapped = error.map { SdkError($0) } ?? .unknown
                self?.delegate?.bannerDidFailToLoadWithError(wrapped)
                self?.levelPlayDelegate?.didFailToLoadWithError(wrapped)
                return
            }
            
            let wrapped = BNISBannerView(adView: view)
            wrapped.load = self.performAuction
            
            self.delegate?.bannerDidLoad(wrapped)
            self.levelPlayDelegate?.didLoad(wrapped, with: ad)
        }
    }
    
    func destroy(_ view: UIView) {
        (view as? BNISBannerView)?.destroy()
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
    
    func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        IronSource.bn.trackAdRevenue(
            ad,
            round: auction.auctionRound(for: ad),
            adType: .banner
        )
    }
}
