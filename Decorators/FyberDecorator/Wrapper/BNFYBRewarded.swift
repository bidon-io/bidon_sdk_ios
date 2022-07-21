//
//  BNFYBRewarded.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import MobileAdvertising
import FairBidSDK


@objc public final class BNFYBRewarded: NSObject {
    private typealias Mediator = FyberRewardedAdDemandProvider
    private typealias RewardedRepository = Repository<String, BNFYBRewarded>
    
    private static let repository = RewardedRepository("com.ads.fyber.rewarded.instances.queue")
    
    @objc public static weak var delegate: BNFYBRewardedDelegate?
    @objc public static weak var auctionDelegate: BNFYBAuctionDelegate?
    
    @objc public static var resolver: AuctionResolver = HigherRevenueAuctionResolver()

    private let placement: String
    
    private var postbid: [RewardedAdDemandProvider] {
        FairBid.bid.bidon.rewardedAdDemandProviders()
    }
    
    private var mediator: Mediator { Mediator(placement: placement) }
    
    private lazy var auction: AuctionController = {
        return try! AuctionControllerBuilder()
            .withAdType(.rewarded)
            .withMediator(mediator)
            .withPostbid(postbid)
            .withDelegate(self)
            .withResolver(BNFYBRewarded.resolver)
            .build()
    }()
    
    @objc public static func request(_ placement: String) {
        instance(placement).request()
    }
    
    @objc public static func isAvailable(_ placement: String) -> Bool {
        instance(placement).isAvailable()
    }
    
    @objc public static func show(
        _ placement: String,
        options: FYBShowOptions = FYBShowOptions()
    ) {
        instance(placement).show(placement, options: options)
    }
    
    private static func instance(_ placement: String) -> BNFYBRewarded {
        guard let instance: BNFYBRewarded = repository[placement] else {
            let instance = BNFYBRewarded(placement: placement)
            repository[placement] = instance
            return instance
        }
        return instance
    }
    
    private init(placement: String) {
        self.placement = placement
        super.init()
    }
    
    
    private func request() {
        auction.load()
    }
    
    private func isAvailable() -> Bool {
        return !auction.isEmpty
    }
    
    private func show(
        _ placement: String,
        options: FYBShowOptions = FYBShowOptions()
    ) {
        auction.finish { [weak self] provider, ad, error in
            guard let ad = ad else { return }
            guard let provider = provider as? RewardedAdDemandProvider else {
                return
            }
            
            provider.rewardDelegate = self
            provider.delegate = self
            
            provider._show(ad: ad, from: options.viewController)
        }
    }
}


extension BNFYBRewarded: AuctionControllerDelegate {
    public func controllerDidStartAuction(_ controller: AuctionController) {
        BNFYBRewarded.delegate?.rewardedWillRequest(placement)
        BNFYBRewarded.auctionDelegate?.didStartAuction(placement: placement)
    }
    
    public func controller(
        _ contoller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    ) {
        BNFYBRewarded.auctionDelegate?.didStartAuctionRound(
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
        BNFYBRewarded.auctionDelegate?.didReceiveAd(
            ad,
            placement: placement
        )
    }
    
    public func controller(
        _ contoller: AuctionController,
        didCompleteRound round: AuctionRound
    ) {
        BNFYBRewarded.auctionDelegate?.didCompleteAuctionRound(
            round.id,
            placement: placement
        )
    }
    
    public func controller(
        _ controller: AuctionController,
        completeAuction winner: Ad
    ) {
        BNFYBRewarded.delegate?.rewardedIsAvailable(placement)
        BNFYBRewarded.auctionDelegate?.didCompleteAuction(
            winner,
            placement: placement
        )
    }
    
    public func controller(
        _ controller: AuctionController,
        failedAuction error: Error
    ) {
        BNFYBRewarded.delegate?.rewardedIsUnavailable(placement)
        BNFYBRewarded.auctionDelegate?.didCompleteAuction(nil, placement: placement)
    }
}


extension BNFYBRewarded: DemandProviderDelegate {
    public func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        BNFYBRewarded.delegate?.rewardedDidShow(placement, impressionData: ad)
    }
    
    public func provider(_ provider: DemandProvider, didHide ad: Ad) {
        BNFYBRewarded.delegate?.rewardedDidDismiss(placement)
    }
    
    public func provider(_ provider: DemandProvider, didClick ad: Ad) {
        BNFYBRewarded.delegate?.rewardedDidClick(placement)
    }
    
    public func provider(
        _ provider: DemandProvider,
        didFailToDisplay ad: Ad,
        error: Error
    ) {
        BNFYBRewarded.delegate?.rewardedDidFail(
            toShow: placement,
            withError: error,
            impressionData: ad
        )
    }
    
    public func provider(_ provider: DemandProvider, didPayRevenueFor ad: Ad) {
        FairBid.bid.trackAdRevenue(
            ad,
            round: auction.auctionRound(for: ad)?.id ?? "",
            adType: .rewarded
        )
    }
}


extension BNFYBRewarded: DemandProviderRewardDelegate {
    public func provider(
        _ provider: DemandProvider,
        didReceiveReward reward: Reward,
        ad: Ad
    ) {
        BNFYBRewarded.delegate?.rewardedDidComplete(
            placement,
            userRewarded: true
        )
    }
}
