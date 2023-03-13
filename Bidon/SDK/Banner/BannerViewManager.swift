//
//  AdContainerViewManager.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 08.07.2022.
//

import Foundation
import UIKit



protocol BannerViewManagerDelegate: AnyObject {
    func viewManager(_ viewManager: BannerViewManager, didRecordImpression impression: Impression)
    func viewManager(_ viewManager: BannerViewManager, didRecordClick impression: Impression)
    func viewManager(_ viewManager: BannerViewManager, willPresentModalView impression: Impression)
    func viewManager(_ viewManager: BannerViewManager, didDismissModalView impression: Impression)
    func viewManager(_ viewManager: BannerViewManager, willLeaveApplication impression: Impression)
}


final internal class BannerViewManager: NSObject {
    static var impressionKey: UInt8 = 0
    
    fileprivate struct AdViewImpression: Impression {
        var impressionId: String = UUID().uuidString
        var auctionId: String
        var auctionConfigurationId: Int
        var ad: Ad
        var format: BannerFormat
        var showTrackedAt: TimeInterval = .nan
        var clickTrackedAt: TimeInterval = .nan
        var rewardTrackedAt: TimeInterval = .nan
        
        init(
            auctionId: String,
            auctionConfigurationId: Int,
            ad: Ad,
            format: BannerFormat
        ) {
            self.auctionId = auctionId
            self.auctionConfigurationId = auctionConfigurationId
            self.ad = ad
            self.format = format
        }
    }
    
    @Injected(\.networkManager)
    private var networkManager: NetworkManager
    
    @Injected(\.sdk)
    private var sdk: Sdk
    
    weak var container: UIView?
    
    private var timer: Timer?
    
    var isAdPresented: Bool {
        guard let container = container else { return false }
        return !container.subviews.isEmpty
    }
    
    weak var delegate: BannerViewManagerDelegate?
    
    var isRefreshGranted: Bool { timer == nil && isAdPresented }
    
    deinit {
        cancelRefreshTimer()
    }
    
    func schedule(
        _ interval: TimeInterval,
        block: (() -> ())?
    ) {
        let timer = Timer(
            timeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            self?.timer = nil
            block?()
        }
        
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }
    
    func cancelRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func present(
        demand: AdViewDemand,
        view: AdViewContainer,
        context: AdViewContext
    ) {
        guard
            let container = container,
            !container.subviews.contains(view)
        else { return }
        
        demand.provider.adViewDelegate = self
        
        let viewsToRemove = container.subviews.compactMap { $0 as? AdViewContainer }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        container.addSubview(view)
        
        let constraints: [NSLayoutConstraint]
        
        if view.isAdaptive {
            constraints = [
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        } else {
            constraints = [
                view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                view.widthAnchor.constraint(equalToConstant: context.format.preferredSize.width),
                view.heightAnchor.constraint(equalToConstant: context.format.preferredSize.height)
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0, options: .curveEaseInOut,
            animations: {
                viewsToRemove.forEach { $0.alpha = 0 }
                view.alpha = 1
            }) { [weak self] _ in
                viewsToRemove.forEach { $0.destroy() }
                self?.trackImpression(adView: view)
            }
        
        view.impression = AdViewImpression(
            auctionId: demand.auctionId,
            auctionConfigurationId: demand.auctionConfigurationId,
            ad: demand.ad,
            format: context.format
        )
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTap))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    private func sendImpressionIfNeeded(
        _ impression: inout AdViewImpression,
        path: Route
    ) {
        guard impression.isTrackingAllowed(path) else { return }
        
        let request = ImpressionRequest { (builder: AdViewImpressionRequestBuilder) in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(sdk.ext)
            builder.withImpression(impression)
            builder.withFormat(impression.format)
            builder.withPath(path)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent impression action '\(path)' with result: \(result)")
        }
        
        impression.markTrackedIfNeeded(path)
    }
    
    private func trackImpression(adView: AdViewContainer) {
        guard var impression = adView.impression else { return }
        
        sendImpressionIfNeeded(&impression, path: .show)
        delegate?.viewManager(self, didRecordImpression: impression)
        
        adView.impression = impression
    }
    
    @objc private
    func didReceiveTap(_ recognizer: UITapGestureRecognizer) {
        guard
            let adView = recognizer.view as? AdViewContainer,
            var impression = adView.impression
        else { return }
        
        sendImpressionIfNeeded(&impression, path: .click)
        delegate?.viewManager(self, didRecordClick: impression)
        
        adView.impression = impression
    }
}


extension BannerViewManager: DemandProviderAdViewDelegate {
    func providerWillPresentModalView(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.viewManager(self, willPresentModalView: impression)
    }
    
    func providerDidDismissModalView(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.viewManager(self, didDismissModalView: impression)
    }
    
    func providerWillLeaveApplication(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.viewManager(self, willLeaveApplication: impression)
    }
}


extension BannerViewManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}


private extension AdViewContainer {
    var impression: BannerViewManager.AdViewImpression? {
        get { objc_getAssociatedObject(self, &BannerViewManager.impressionKey) as? BannerViewManager.AdViewImpression }
        set { objc_setAssociatedObject(self, &BannerViewManager.impressionKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func destroy() {
        impression = nil
        removeFromSuperview()
    }
}
