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
    @objc public var autorefreshInterval: TimeInterval = 5 {
        didSet { scheduleRefreshIfNeeded() }
    }
    
    @objc public var isAutorefreshing: Bool = true {
        didSet {
            isAutorefreshing ?
            scheduleRefreshIfNeeded() :
            viewManager.cancelRefreshTimer()
        }
    }
    
    @objc public var rootViewController: UIViewController?

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
        guard !viewManager.isAdPresented else { return }
        refresh()
    }

    @objc public func loadAd() {
        let ctx = AdViewContext(
            format: .banner,
            size: AdViewFormat.banner.preferredSize,
            isAdaptive: true,
            rootViewController: rootViewController
        )
        
        adManager.loadAd(context: ctx)
    }
    
    private func layout(adView: AdViewContainer) {
        DispatchQueue.main.async { [weak self, weak adView] in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            Logger.verbose("Banner \(self) did layout ad view \(adView), size:)")
            self.viewManager.layout(view: adView, size: self.bounds.size)
            self.scheduleRefreshIfNeeded()
        }
    }
    
    private final func refresh() {
        Logger.verbose("Banner \(self) will refresh ad view")
        guard
            let provider = adManager.demand?.provider as? AdViewDemandProvider,
            let ad = adManager.demand?.ad,
            let adView = provider.container(for: ad)
        else { return }
    
        layout(adView: adView)
    }
    
    private final func scheduleRefreshIfNeeded() {
        guard isAutorefreshing, autorefreshInterval > 0, viewManager.isRefreshGranted
        else { return }
        weak var weakSelf = self
        Logger.verbose("Banner \(self) did start refresh timer with interval: \(autorefreshInterval)s")
        loadAd()
        viewManager.schedule(autorefreshInterval, block: weakSelf?.refresh)
    }
}


extension Banner: BannerAdManagerDelegate {
    func didFailToLoad(_ error: Error) {
        
    }
    
    func didLoad(_ ad: Ad) {
        refresh()
    }
    
    func controllerDidStartAuction(_ controller: AuctionController) {
        
    }
    
    func controller(_ controller: AuctionController, didStartRound round: AuctionRound, pricefloor: Price) {
        
    }
    
    func controller(_ controller: AuctionController, didReceiveAd ad: Ad, provider: DemandProvider) {
        
    }
    
    func controller(_ controller: AuctionController, didCompleteRound round: AuctionRound) {
        
    }
    
    func controller(_ controller: AuctionController, completeAuction winner: Ad) {
        
    }
    
    func controller(_ controller: AuctionController, failedAuction error: Error) {
        
    }
}
