//
//  BNMARewardedAd.swift
//  AppLovinDecorator
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation
import AppLovinSDK
import BidOn


@objc
final public class BNMARewardedAd: NSObject {
    private typealias Mediator = AppLovinFullscreenDemandProvider<MARewardedAd>
    private typealias RewardedAdRepository = Repository<String, BNMARewardedAd>
    
    private static let repository = RewardedAdRepository("com.ads.applovin.rewarded.instances.queue")
    
    @objc public let adUnitIdentifier: String
    
    @objc public weak var delegate: BNMARewardedAdDelegate?
    @objc public weak var auctionDelegate: BNMAuctionDelegate?
    @objc public weak var revenueDelegate: BNMAAdRevenueDelegate?
    @objc public weak var adReviewDelegate: BNMAAdReviewDelegate?
    
    @objc public var resolver: AuctionResolver = HigherRevenueAuctionResolver()

    private let sdk: ALSdk!
    private var displayArguments: FullscreenAdDisplayArguments?
    
    @objc public var isReady: Bool {
        !auction.isEmpty
    }
    
    private var postbid: [RewardedAdDemandProvider] {
        sdk.bn.bidon.rewardedAdDemandProviders()
    }
    
    private lazy var mediator: Mediator = {
        weak var weakSelf = self
        
        let mediator = Mediator(
            adUnitIdentifier: adUnitIdentifier,
            displayArguments: weakSelf?.displayArguments,
            sdk: sdk
        )
                
        mediator.fullscreenAd.adReviewDelegate = self
        
        return mediator
    }()
    
    private lazy var auction: AuctionController = {
        return try! AuctionControllerBuilder()
            .withAdType(.rewarded)
            .withMediator(mediator)
            .withPostbid(postbid)
            .withDelegate(self)
            .withResolver(resolver)
            .build()
    }()
    
    @objc public static func shared(
        withAdUnitIdentifier adUnitIdentifier: String
    ) -> BNMARewardedAd {
        return shared(adUnitIdentifier)
    }
    
    @objc public static func shared(
        withAdUnitIdentifier adUnitIdentifier: String,
        sdk: ALSdk
    ) -> BNMARewardedAd {
        return shared(adUnitIdentifier, sdk: sdk)
    }
    
    private static func shared(
        _ adUnitIdentifier: String,
        sdk: ALSdk! = ALSdk.shared()
    ) -> BNMARewardedAd {
        guard let instance: BNMARewardedAd = repository[adUnitIdentifier] else {
            let instance = self.init(adUnitIdentifier: adUnitIdentifier, sdk: sdk)
            repository[adUnitIdentifier] = instance
            return instance
        }
        
        return instance
    }
    
    private init(
        adUnitIdentifier: String,
        sdk: ALSdk! = ALSdk.shared()
    ) {
        self.adUnitIdentifier = adUnitIdentifier
        self.sdk = sdk
        super.init()
    }
    
    @objc(loadAd)
    public func load() {
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
            guard let provider = provider as? RewardedAdDemandProvider else {
                self?.delegate?.didFail(toDisplay: ad, withError: SdkError(error))
                return
            }
            
            provider.delegate = self
            provider.rewardDelegate = self
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


extension BNMARewardedAd: AuctionControllerDelegate {
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
    
    public func controller(
        _ contoller: AuctionController,
        didCompleteRound round: AuctionRound
    ) {
        auctionDelegate?.didCompleteAuctionRound(round.id)
    }
    
    public func controller(
        _ controller: AuctionController,
        completeAuction winner: Ad
    ) {
        auctionDelegate?.didCompleteAuction(winner)
        delegate?.didLoad(winner)
    }
    
    public func controller(
        _ controller: AuctionController,
        failedAuction error: Error
    ) {
        auctionDelegate?.didCompleteAuction(nil)
        
        delegate?.didFailToLoadAd(
            forAdUnitIdentifier: adUnitIdentifier,
            withError: error
        )
    }
}


extension BNMARewardedAd: MAAdRevenueDelegate, MAAdReviewDelegate {
    public func didPayRevenue(for ad: MAAd) {
        revenueDelegate?.didPayRevenue(for: ad.wrapped)
    }
    
    public func didGenerateCreativeIdentifier(
        _ creativeIdentifier: String,
        for ad: MAAd
    ) {
        adReviewDelegate?.didGenerateCreativeIdentifier(
            creativeIdentifier,
            for: ad.wrapped
        )
    }
}


extension BNMARewardedAd: DemandProviderDelegate {
    public func provider(
        _ provider: DemandProvider,
        didPresent ad: Ad
    ) {
        delegate?.didDisplay(ad)
    }
    
    public func provider(
        _ provider: DemandProvider,
        didHide ad: Ad
    ) {
        delegate?.didHide(ad)
    }
    
    public func provider(
        _ provider: DemandProvider,
        didClick ad: Ad
    ) {
        delegate?.didClick(ad)
    }
    
    public func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        sdk.bn.trackAdRevenue(
            ad,
            adType: .rewarded,
            round: auction.auctionRound(for: ad)?.id ?? ""
        )
        revenueDelegate?.didPayRevenue(for: ad)
    }
    
    public func provider(
        _ provider: DemandProvider,
        didFailToDisplay ad: Ad,
        error: Error
    ) {
        delegate?.didFail(toDisplay: ad, withError: error)
    }
}


extension BNMARewardedAd: DemandProviderRewardDelegate {
    public func provider(
        _ provider: DemandProvider,
        didReceiveReward reward: Reward,
        ad: Ad
    ) {
        delegate?.didRewardUser(for: ad, with: reward)
    }
}
