//
//  AdContainerView.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit


@objc(BDBanner)
public final class Banner: UIView, AdView {
    @objc public var autorefreshInterval: TimeInterval = 15 {
        didSet { scheduleRefreshIfNeeded() }
    }
    
    @objc public var isAutorefreshing: Bool = true {
        didSet {
            isAutorefreshing ?
            scheduleRefreshIfNeeded() :
            viewManager.cancelRefreshTimer()
        }
    }
    
    @objc public var format: AdViewFormat = .banner
    
    @objc public var rootViewController: UIViewController?

    @objc public var delegate: AdViewDelegate?
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    private lazy var viewManager: BannerViewManager = {
        let manager = BannerViewManager()
        manager.container = self
        return manager
    }()
    
    private lazy var adManager: BannerAdManager = {
        let manager = BannerAdManager()
        manager.delegate = self
        return manager
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        refreshIfNeeded()
    }

    @objc public func loadAd() {
        let ctx = AdViewContext(
            format: format,
            size: format.preferredSize,
            isAdaptive: true,
            rootViewController: rootViewController
        )
        
        adManager.loadAd(context: ctx)
    }
    
    private func layout(
        adView: AdViewContainer,
        provider: AdViewDemandProvider
    ) {
        DispatchQueue.main.async { [weak self, weak adView] in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            Logger.verbose("Banner \(self) did layout ad view \(adView), size:)")
            
            self.viewManager.layout(
                view: adView,
                provider: provider,
                size: self.format.preferredSize
            )
            
            self.scheduleRefreshIfNeeded()
        }
    }
    
    private final func refreshIfNeeded() {
        guard
            let provider = adManager.demand?.provider as? AdViewDemandProvider,
            let ad = adManager.demand?.ad,
            let adView = provider.container(for: ad)
        else { return }
        
        if viewManager.isRefreshGranted {
            Logger.verbose("Banner \(self) will refresh ad view")
        
            layout(adView: adView, provider: provider)
        } else if !viewManager.isAdPresented {
            Logger.verbose("Banner \(self) will display ad view")
               
            layout(adView: adView, provider: provider)
        }
    }
    
    private final func scheduleRefreshIfNeeded() {
        guard isAutorefreshing, autorefreshInterval > 0, viewManager.isRefreshGranted
        else { return }
        weak var weakSelf = self
        
        Logger.verbose("Banner \(self) did start refresh timer with interval: \(autorefreshInterval)s")
        
        adManager.prepareForReuse()
        viewManager.schedule(autorefreshInterval, block: weakSelf?.refreshIfNeeded)
        
        loadAd()
    }
}


extension Banner: BannerAdManagerDelegate {
    func didFailToLoad(_ error: Error) {
        delegate?.adObject(self, didFailToLoadAd: error)
    }
    
    func didLoad(_ ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
        refreshIfNeeded()
    }
    
    func controllerDidStartAuction(_ controller: AuctionController) {
        delegate?.adObjectDidStartAuction?(self)
    }
    
    func controller(
        _ controller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    ) {
        delegate?.adObject?(
            self,
            didStartAuctionRound: round.id,
            pricefloor: pricefloor
        )
    }
    
    func controller(
        _ controller: AuctionController,
        didReceiveAd ad: Ad,
        provider: DemandProvider
    ) {
        provider.revenueDelegate = self
        delegate?.adObject?(
            self,
            didReceiveBid: ad
        )
    }
    
    func controller(
        _ controller: AuctionController,
        didCompleteRound round: AuctionRound
    ) {
        delegate?.adObject?(
            self,
            didCompleteAuctionRound: round.id
        )
    }
    
    func controller(
        _ controller: AuctionController,
        completeAuction winner: Ad
    ) {
        delegate?.adObject?(self, didCompleteAuction: winner)
    }
    
    func controller(
        _ controller: AuctionController,
        failedAuction error: Error
    ) {
        delegate?.adObject?(self, didCompleteAuction: nil)
    }
}


extension Banner: DemandProviderRevenueDelegate {
    public func provider(
        _ provider: DemandProvider,
        didPayRevenueFor ad: Ad
    ) {
        delegate?.adObject?(self, didPayRevenue: ad)
        sdk.trackAdRevenue(ad, adType: .banner)
    }
}
