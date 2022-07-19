//
//  BNMAAdiew.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import UIKit
import AppLovinSDK
import MobileAdvertising


@objc public final class BNMAAdView: AdContainerView {
    private typealias Mediator = AppLovinAdViewDemandProvider
    
    @objc public var adUnitIdentifier: String
    @objc public var placement: String?
    
    @objc private(set) public weak var adFormat: MAAdFormat?
    
    @objc public weak var delegate: BNMAAdViewAdDelegate?
    @objc public weak var auctionDelegate: BNMAuctionDelegate?
    @objc public weak var revenueDelegate: BNMAAdRevenueDelegate?
    @objc public weak var adReviewDelegate: BNMAAdReviewDelegate?
    
    @objc public var resolver: AuctionResolver = HigherRevenueAuctionResolver()

    private var extraParameters: [String: String] = [:]
    private let sdk: ALSdk!
    private var fetchCompletion: ((AdView?) -> ())?
    
    private lazy var mediator: Mediator = {
        weak var weakSelf = self
        
        let mediator = Mediator(
            adUnitIdentifier: adUnitIdentifier,
            sdk: sdk,
            adFormat: adFormat ?? .banner
        )
        
        mediator.ad.adReviewDelegate = self
        mediator.ad.revenueDelegate = self
        
        return mediator
    }()
    
    private var postbid: [AdViewDemandProvider] {
        let isAdaptive = extraParameters["adaptive_banner"]
            .map { $0 as NSString }
            .map { $0.boolValue } ?? false
        
        let ctx = AdViewContext(adFormat?.fmt ?? .banner, isAdaptive: isAdaptive)
        
        return sdk.bid.bidon.adViewDemandProviders(ctx)
    }
    
    private lazy var auction: AuctionController = {
        return try! AuctionControllerBuilder()
            .withMediator(mediator)
            .withPostbid(postbid)
            .withDelegate(self)
            .withResolver(resolver)
            .build()
    }()
    
    public override func preferredSize() -> CGSize {
        return adFormat?.size ?? AdViewFormat.banner.preferredSize
    }
    
    public override func fetch(
        _ completion: @escaping (AdView?) -> ()
    ) {
        guard
            let ad = auction.winner,
            let provider: AdViewDemandProvider = auction.provider(for: ad)
        else {
            self.fetchCompletion = completion
            return
        }
        completion(provider.adView(for: ad))
    }
    
    @objc public convenience init(
        adUnitIdentifier: String
    ) {
        self.init(adUnitIdentifier)
    }
    
    @objc public convenience init(
        adUnitIdentifier: String,
        sdk: ALSdk
    ) {
        self.init(adUnitIdentifier, sdk: sdk)
    }
    
    @objc public convenience init(
        adUnitIdentifier: String,
        adFormat: MAAdFormat
    ) {
        self.init(adUnitIdentifier, adFormat: adFormat)
    }
    
    @objc public convenience init(
        adUnitIdentifier: String,
        adFormat: MAAdFormat,
        sdk: ALSdk
    ) {
        self.init(adUnitIdentifier, adFormat: adFormat, sdk: sdk)
    }
    
    private init(
        _ adUnitIdentifier: String,
        adFormat: MAAdFormat = .banner,
        sdk: ALSdk! = ALSdk.shared()
    ) {
        self.adUnitIdentifier = adUnitIdentifier
        self.adFormat = adFormat
        self.sdk = sdk
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public override func loadAd() {
        auction.load()
    }
    
    @objc public func startAutoRefresh() {
        isAutorefreshing = true
    }
    
    @objc public func stopAutoRefresh() {
        isAutorefreshing = false
    }
    
    @objc public func setExtraParameterForKey(_ key: String, value: String?) {
        extraParameters[key] = value
        mediator.ad.setExtraParameterForKey(key, value: value)
    }
    
    @objc public func setLocalExtraParameterForKey(_ key: String, value: Any?) {
        mediator.ad.setLocalExtraParameterForKey(key, value: value)
    }
}


extension BNMAAdView: AuctionControllerDelegate {
    public func controllerDidStartAuction(_ controller: AuctionController) {
        auctionDelegate?.didStartAuction()
    }
    
    public func controller(
        _ contoller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    ) {
        auctionDelegate?.didStartAuctionRound(
            round.id,
            pricefloor: pricefloor
        )
    }
    
    public func controller(
        _ controller: AuctionController,
        didReceiveAd ad: Ad,
        provider: DemandProvider
    ) {
        auctionDelegate?.didReceiveAd(ad)
    }
    
    public func controller(_ contoller: AuctionController, didCompleteRound round: AuctionRound) {
        auctionDelegate?.didCompleteAuctionRound(round.id)
    }
    
    public func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        auctionDelegate?.didCompleteAuction(winner)
        delegate?.didLoad(winner)
        
        guard let provider: AdViewDemandProvider = controller.provider(for: winner) else { return }
        fetchCompletion?(provider.adView(for: winner))
    }
    
    public func controller(_ controller: AuctionController, failedAuction error: Error) {
        auctionDelegate?.didCompleteAuction(nil)
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
    }
}


extension BNMAAdView: MAAdRevenueDelegate, MAAdReviewDelegate {
    public func didPayRevenue(for ad: MAAd) {
        revenueDelegate?.didPayRevenue(for: ad.wrapped)
    }
    
    public func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: MAAd) {
        adReviewDelegate?.didGenerateCreativeIdentifier(creativeIdentifier, for: ad.wrapped)
    }
}


extension BNMAAdView: DemandProviderDelegate {
    public func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.didDisplay(ad)
    }
    
    public func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.didHide(ad)
    }
    
    public func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.didClick(ad)
    }
    
    public func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.didFail(toDisplay: ad, withError: error)
    }
    
    public func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        sdk.bid.trackAdRevenue(
            ad,
            adType: .banner,
            round: auction.auctionRound(for: ad)?.id ?? ""
        )
        revenueDelegate?.didPayRevenue(for: ad)
    }
}


extension BNMAAdView: DemandProviderAdViewDelegate {
    public func provider(_ provider: AdViewDemandProvider, willPresentModalView ad: Ad) {
        delegate?.didExpand(ad)
    }
    
    public func provider(_ provider: AdViewDemandProvider, didDismissModalView ad: Ad) {
        delegate?.didCollapse(ad)
    }
    
    public func provider(_ provider: AdViewDemandProvider, willLeaveApplication ad: Ad) {}
}
