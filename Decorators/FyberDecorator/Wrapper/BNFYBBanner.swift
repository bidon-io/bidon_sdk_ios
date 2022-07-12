//
//  BNFYBBanner.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising
import FairBidSDK


@objc public final class BNFYBBanner: NSObject {
    private typealias Mediator = FyberBannerDemandProvider
    private typealias BannerRepository = Repository<String, BNFYBBanner>
    
    private static let repository = BannerRepository("com.ads.fyber.banner.instances.queue")
    
    @objc public static weak var delegate: BNFYBBannerDelegate?
    @objc public static weak var auctionDelegate: BNFYBAuctionDelegate?
    
    private let placement: String
    private var shouldLayoutOnLoad: Bool = false
    
    private var view: BNFYBBannerAdView?
    private var position = FYBBannerAdViewPosition.top
    private weak var container: UIView?
    
    private var postbid: [AdViewDemandProvider] {
        let ctx = AdViewContext(.banner)
        return FairBid.bid.bidon.adViewDemandProviders(ctx)
    }
    
    private var mediator: Mediator { Mediator(placement: placement) }
    
    private lazy var auction: AuctionController = {
        return try! AuctionControllerBuilder()
            .withMediator(mediator)
            .withPostbid(postbid)
            .withDelegate(self)
            .withResolver(HigherRevenueAuctionResolver())
            .build()
    }()
    
    @objc public static func show(
        in view: UIView,
        position: FYBBannerAdViewPosition,
        options: FYBBannerOptions
    ) {
        instance(options.placementId).show(
            in: view,
            position: position,
            options: options
        )
    }
    
    @objc public static func request(_ placement: String) {
        instance(placement).request()
    }
    
    @objc public static func isAvailable(_ placement: String) -> Bool {
        instance(placement).isAvailable()
    }
    
    private static func instance(_ placement: String) -> BNFYBBanner {
        guard let instance: BNFYBBanner = repository[placement] else {
            let instance = BNFYBBanner(placement: placement)
            repository[placement] = instance
            return instance
        }
        return instance
    }
    
    private init(placement: String) {
        self.placement = placement
        super.init()
    }
    
    private func show(
        in view: UIView,
        position: FYBBannerAdViewPosition,
        options: FYBBannerOptions
    ) {
        self.position = position
        self.container = view
        self.shouldLayoutOnLoad = self.view == nil
        
        request()
        layoutIfNeeded()
    }
    
    private func request() {
        auction.load()
    }
    
    private func isAvailable() -> Bool {
        return !auction.isEmpty
    }
    
    private func layoutIfNeeded() {
        guard
            shouldLayoutOnLoad,
            let view = view,
            let container = container
        else { return }
        
        container.subviews
            .compactMap { $0 as? BNFYBBannerAdView }
            .forEach { $0.removeFromSuperview() }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        var constraints: [NSLayoutConstraint] = [
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor)
        ]
        
        switch position {
        case .top:
            constraints += [
                view.topAnchor.constraint(equalTo: container.topAnchor)
            ]
        case .bottom:
            constraints += [
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ]
        default:
            break
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}


extension BNFYBBanner: AuctionControllerDelegate {
    public func controllerDidStartAuction(_ controller: AuctionController) {
        BNFYBBanner.delegate?.bannerWillRequest(placement)
        BNFYBBanner.auctionDelegate?.didStartAuction(placement: placement)
    }
    
    public func controller(
        _ contoller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    ) {
        BNFYBBanner.auctionDelegate?.didStartAuctionRound(
            round.id,
            placement: placement,
            pricefloor: pricefloor
        )
    }
    
    public func controller(
        _ controller: AuctionController,
        didReceiveAd ad: Ad,
        provider: DemandProvider
    ) {
        BNFYBBanner.auctionDelegate?.didReceiveAd(
            ad,
            placement: placement
        )
    }
    
    public func controller(
        _ contoller: AuctionController,
        didCompleteRound round: AuctionRound
    ) {
        BNFYBBanner.auctionDelegate?.didCompleteAuctionRound(
            round.id,
            placement: placement
        )
    }
    
    public func controller(
        _ controller: AuctionController,
        completeAuction winner: Ad
    ) {
        
        guard
            let ad = auction.winner,
            let provider: AdViewDemandProvider = auction.provider(for: ad)
        else {
            BNFYBBanner.delegate?.bannerDidFail(toLoad: placement, withError: SDKError("Invalid ad was recieved"))
            return
        }
        
        let options = FYBBannerOptions()
        options.placementId = placement
        options.presentingViewController = UIApplication.shared.topViewContoller
        
        let view = BNFYBBannerAdView(
            ad: ad,
            provider: provider,
            options: options
        )
        
        BNFYBBanner.delegate?.bannerDidLoad(view)
        
        BNFYBBanner.auctionDelegate?.didCompleteAuction(
            winner,
            placement: placement
        )
        
        self.view = view
        
        layoutIfNeeded()
    }
    
    public func controller(
        _ controller: AuctionController,
        failedAuction error: Error
    ) {
        BNFYBBanner.delegate?.bannerDidFail(toLoad: placement, withError: error)
        BNFYBBanner.auctionDelegate?.didCompleteAuction(nil, placement: placement)
    }
}


extension BNFYBBanner: DemandProviderDelegate {
    public func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        guard let view = view else { return }
        BNFYBBanner.delegate?.bannerDidShow(view, impressionData: ad)
    }
    
    
    public func provider(_ provider: DemandProvider, didClick ad: Ad) {
        guard let view = view else { return }
        BNFYBBanner.delegate?.bannerDidClick(view)
    }
    
    public func provider(_ provider: DemandProvider, didHide ad: Ad) {}
    public func provider(
        _ provider: DemandProvider,
        didFailToDisplay ad: Ad,
        error: Error
    ) {}
}


extension BNFYBBanner: DemandProviderAdViewDelegate {
    public func provider(_ provider: AdViewDemandProvider, didExpandAd ad: Ad) {
//        BNFYBBanner.delegate?.bannerWillPresentModalView(<#T##banner: BNFYBBannerAdView##BNFYBBannerAdView#>)
    }
    
    public func provider(_ provider: AdViewDemandProvider, didCollapseAd ad: Ad) {
        
    }
}
