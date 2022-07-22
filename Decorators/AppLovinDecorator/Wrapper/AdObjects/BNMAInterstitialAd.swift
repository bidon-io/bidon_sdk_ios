//
//  InterstitialAd.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 28.06.2022.
//

import Foundation
import AppLovinSDK
import MobileAdvertising


@objc
final public class BNMAInterstitialAd: NSObject {
    private typealias Mediator = AppLovinFullscreenDemandProvider<MAInterstitialAd>

    @objc public let adUnitIdentifier: String
    
    @objc public weak var delegate: BNMAAdDelegate?
    @objc public weak var auctionDelegate: BNMAuctionDelegate?
    @objc public weak var revenueDelegate: BNMAAdRevenueDelegate?
    @objc public weak var adReviewDelegate: BNMAAdReviewDelegate?
    
    @objc public var resolver: AuctionResolver = HigherRevenueAuctionResolver()

    private let sdk: ALSdk!
    private var displayArguments: FullscreenAdDisplayArguments?
    
    @objc public var isReady: Bool {
        !auction.isEmpty
    }
    
    private var postbid: [InterstitialDemandProvider] {
        sdk.bid.bidon.interstitialDemandProviders()
    }
    
    private lazy var mediator: Mediator = {
        weak var weakSelf = self
        
        let mediator = Mediator(
            adUnitIdentifier: adUnitIdentifier,
            displayArguments: weakSelf?.displayArguments,
            sdk: sdk
        )
        
        mediator.fullscreenAd.revenueDelegate = self
        mediator.fullscreenAd.adReviewDelegate = self
        
        return mediator
    }()
    
    private lazy var auction: AuctionController = {
        return try! AuctionControllerBuilder()
            .withAdType(.interstitial)
            .withMediator(mediator)
            .withPostbid(postbid)
            .withDelegate(self)
            .withResolver(resolver)
            .build()
    }()
    
    @objc public init(
        adUnitIdentifier: String
    ) {
        self.adUnitIdentifier = adUnitIdentifier
        self.sdk = ALSdk.shared()
        super.init()
    }
    
    @objc public init(
        adUnitIdentifier: String,
        sdk: ALSdk
    ) {
        self.sdk = sdk
        self.adUnitIdentifier = adUnitIdentifier
        super.init()
    }
    
    @objc(loadAd) public func load() {
        auction.load()
    }
    
    @objc(showAd)
    public func show() {
        show(forPlacement: nil)
    }
    
    @objc(showAdForPlacement:)
    public func show(
        forPlacement: String?
    ) {
        show(
            forPlacement: forPlacement,
            customData: nil
        )
    }
    
    @objc(showAdForPlacement:customData:)
    public func show(
        forPlacement: String?,
        customData: String?
    ) {
        show(
            forPlacement: forPlacement,
            customData: customData,
            viewController: nil
        )
    }
    
    @objc(showAdForPlacement:customData:viewController:)
    public func show(
        forPlacement: String?,
        customData: String?,
        viewController: UIViewController?
    ) {
        displayArguments = .init(
            placement: forPlacement,
            customData: customData
        )
        
        auction.finish { [weak self] provider, ad, error in
            guard let ad = ad else { return }
            guard let provider = provider as? InterstitialDemandProvider else {
                self?.delegate?.didFail(toDisplay: ad, withError: SDKError(error))
                return
            }
            
            provider.delegate = self
            provider._show(ad: ad, from: viewController)
        }
    }
    
    @objc public func setExtraParameterForKey(_ key: String, value: String?) {
        mediator.fullscreenAd.setExtraParameterForKey(key, value: value)
    }
    
    @objc public func setLocalExtraParameterForKey(_ key: String, value: Any?) {
        mediator.fullscreenAd.setLocalExtraParameterForKey(key, value: value)
    }
}


extension BNMAInterstitialAd: AuctionControllerDelegate {
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
    }
    
    public func controller(_ controller: AuctionController, failedAuction error: Error) {
        auctionDelegate?.didCompleteAuction(nil)
        delegate?.didFailToLoadAd(forAdUnitIdentifier: adUnitIdentifier, withError: error)
    }
}


extension BNMAInterstitialAd: MAAdRevenueDelegate, MAAdReviewDelegate {
    public func didPayRevenue(for ad: MAAd) {
        revenueDelegate?.didPayRevenue(for: ad.wrapped)
    }
    
    public func didGenerateCreativeIdentifier(_ creativeIdentifier: String, for ad: MAAd) {
        adReviewDelegate?.didGenerateCreativeIdentifier(creativeIdentifier, for: ad.wrapped)
    }
}


extension BNMAInterstitialAd: DemandProviderDelegate {
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
            adType: .interstitial,
            round: auction.auctionRound(for: ad)?.id ?? ""
        )
        revenueDelegate?.didPayRevenue(for: ad)
    }
}
