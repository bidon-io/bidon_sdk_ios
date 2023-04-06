//
//  AdContainerViewManager.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 08.07.2022.
//

import Foundation
import UIKit



protocol BannerViewManagerDelegate: AnyObject {
    func viewManager(_ viewManager: BannerViewManager, didRecordImpression ad: Ad)
    func viewManager(_ viewManager: BannerViewManager, didRecordClick ad: Ad)
    func viewManager(_ viewManager: BannerViewManager, willPresentModalView ad: Ad)
    func viewManager(_ viewManager: BannerViewManager, didDismissModalView ad: Ad)
    func viewManager(_ viewManager: BannerViewManager, willLeaveApplication ad: Ad)
}


final internal class BannerViewManager: NSObject {
    static var impressionKey: UInt8 = 0
    
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
    
    var extras: [String: AnyHashable] = [:]
    
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
        bid: AdViewBid,
        view: AdViewContainer,
        context: AdViewContext
    ) {
        guard
            let container = container,
            !container.subviews.contains(view)
        else { return }
        
        bid.provider.adViewDelegate = self
        
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
            bid: bid,
            format: context.format
        )
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTap))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    func notify(
        loss ad: Ad,
        winner demandId: String,
        eCPM: Price
    ) {
        guard
            let adView = container?.subviews.first(where: { $0 is AdViewContainer }) as? AdViewContainer,
            let impression = adView.impression,
            impression.ad.id == ad.id
        else { return }
        
        let request = LossRequest { (builder: AdViewLossRequestBuilder) in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(extras, sdk.extras)
            builder.withImpression(impression)
            builder.withFormat(impression.format)
            builder.withExternalWinner(demandId: demandId, eCPM: eCPM)
        }
        
        networkManager.perform(request: request) { result in
            Logger.debug("Sent loss with result: \(result)")
        }
        
        adView.destroy()
    }

    private func sendImpressionIfNeeded(
        _ impression: inout AdViewImpression,
        path: Route
    ) {
        guard impression.isTrackingAllowed(path) else { return }
        
        let request = ImpressionRequest { (builder: AdViewImpressionRequestBuilder) in
            builder.withEnvironmentRepository(sdk.environmentRepository)
            builder.withTestMode(sdk.isTestMode)
            builder.withExt(extras, sdk.extras)
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
        
        let ad = AdContainer(impression: impression)
        delegate?.viewManager(self, didRecordImpression: ad)
        
        adView.impression = impression
    }
    
    @objc private
    func didReceiveTap(_ recognizer: UITapGestureRecognizer) {
        guard
            let adView = recognizer.view as? AdViewContainer,
            var impression = adView.impression
        else { return }
        
        sendImpressionIfNeeded(&impression, path: .click)
        
        let ad = AdContainer(impression: impression)
        delegate?.viewManager(self, didRecordClick: ad)
        
        adView.impression = impression
    }
}


extension BannerViewManager: DemandProviderAdViewDelegate {
    func providerWillPresentModalView(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        
        let ad = AdContainer(impression: impression)
        delegate?.viewManager(self, willPresentModalView: ad)
    }
    
    func providerDidDismissModalView(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        
        let ad = AdContainer(impression: impression)
        delegate?.viewManager(self, didDismissModalView: ad)
    }
    
    func providerWillLeaveApplication(
        _ provider: any AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        
        let ad = AdContainer(impression: impression)
        delegate?.viewManager(self, willLeaveApplication: ad)
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
    var impression: AdViewImpression? {
        get { objc_getAssociatedObject(self, &BannerViewManager.impressionKey) as? AdViewImpression }
        set { objc_setAssociatedObject(self, &BannerViewManager.impressionKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func destroy() {
        impression = nil
        removeFromSuperview()
    }
}
