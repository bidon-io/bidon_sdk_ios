//
//  AdContainerView.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 08.07.2022.
//

import Foundation
import UIKit


@objc(BDNBannerView)
public final class BannerView: UIView, AdView {
    @available(*, unavailable)
    @objc public var autorefreshInterval: TimeInterval = 15 {
        didSet { scheduleRefreshIfNeeded() }
    }
    
    @available(*, unavailable)
    @objc public var isAutorefreshing: Bool = false // {
    //        didSet {
    //            isAutorefreshing ? scheduleRefreshIfNeeded() : viewManager.cancelRefreshTimer()
    //        }
    //    }
    
    @objc public let placement: String
    
    @objc public var format: BannerFormat = .banner
    
    @objc public var rootViewController: UIViewController?
    
    @objc public var delegate: AdViewDelegate?
    
    @objc public var isReady: Bool { return adManager.bid != nil }
    
    @objc private(set) public
    lazy var extras: [String : AnyHashable] = [:] {
        didSet {
            adManager.extras = extras
            viewManager.extras = extras
        }
    }
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    private var context: AdViewContext {
        return AdViewContext(
            format: format,
            size: format.preferredSize,
            rootViewController: rootViewController
        )
    }
    
    private lazy var viewManager: BannerViewManager = {
        let manager = BannerViewManager()
        manager.container = self
        manager.delegate = self
        return manager
    }()
    
    private lazy var adManager: BannerAdManager = {
        let manager = BannerAdManager()
        manager.delegate = self
        return manager
    }()
    
    @objc
    public init(
        frame: CGRect,
        placement: String = BidonSdk.defaultPlacement
    ) {
        self.placement = placement
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        refreshIfNeeded()
    }
    
    @objc public func setExtraValue(
        _ value: AnyHashable?,
        for key: String
    ) {
        extras[key] = value
    }
    
    @objc public func loadAd(
        with pricefloor: Price = BidonSdk.defaultMinPrice
    ) {
        adManager.loadAd(
            context: context,
            pricefloor: pricefloor
        )
    }
    
    @objc(notifyLossAd:winner:eCPM:)
    public func notify(
        loss ad: Ad,
        winner demandId: String,
        eCPM: Price
    ) {
        viewManager.notify(
            loss: ad,
            winner: demandId,
            eCPM: eCPM
        )
    }
    
    private final func refreshIfNeeded() {
        guard
            let bid = adManager.bid,
            let adView = bid.provider.container(opaque: bid.ad),
            superview != nil
        else { return }
        
        if viewManager.isRefreshGranted || !viewManager.isAdPresented {
            Logger.verbose("Banner \(self) will refresh ad view")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.adManager.prepareForReuse()
                self.viewManager.present(
                    bid: bid,
                    view: adView,
                    context: self.context
                )
            }
        }
    }
    
    // TODO: Autorefresh feature is not implemented
    private final func scheduleRefreshIfNeeded() {
//        guard
//            isAutorefreshing,
//            autorefreshInterval > 0,
//            viewManager.isRefreshGranted
//        else { return }
//
//        weak var weakSelf = self
//
//        Logger.verbose("Banner \(self) did start refresh timer with interval: \(autorefreshInterval)s")
//
//        adManager.prepareForReuse()
//        viewManager.schedule(autorefreshInterval, block: weakSelf?.refreshIfNeeded)
//
//        loadAd(with: .zero)
    }
}


extension BannerView: BannerAdManagerDelegate {
    func adManager(_ adManager: BannerAdManager, didFailToLoad error: SdkError) {
        delegate?.adObject(self, didFailToLoadAd: error.nserror)
    }
    
    func adManager(_ adManager: BannerAdManager, didLoad ad: Ad) {
        delegate?.adObject(self, didLoadAd: ad)
        refreshIfNeeded()
    }
    
    func adManager(_ adManager: BannerAdManager, didPayRevenue revenue: AdRevenue, ad: Ad) {
        delegate?.adObject?(self, didPay: revenue, ad: ad)
    }
}


extension BannerView: BannerViewManagerDelegate {
    func viewManager(_ viewManager: BannerViewManager, didRecordImpression ad: Ad) {
        scheduleRefreshIfNeeded()
        delegate?.adObject?(self, didRecordImpression: ad)
    }
    
    func viewManager(_ viewManager: BannerViewManager, didRecordClick ad: Ad) {
        delegate?.adObject?(self, didRecordClick: ad)
    }
    
    func viewManager(_ viewManager: BannerViewManager, willPresentModalView ad: Ad) {
        delegate?.adView(self, willPresentScreen: ad)
    }
    
    func viewManager(_ viewManager: BannerViewManager, didDismissModalView ad: Ad) {
        delegate?.adView(self, didDismissScreen: ad)
    }
    
    func viewManager(_ viewManager: BannerViewManager, willLeaveApplication ad: Ad) {
        delegate?.adView(self, willLeaveApplication: ad)
    }
}


