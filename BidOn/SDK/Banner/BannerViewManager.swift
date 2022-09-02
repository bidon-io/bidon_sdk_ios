//
//  AdContainerViewManager.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit



protocol BannerViewManagerDelegate: AnyObject {
    func manager(_ manager: BannerViewManager, didRecordImpression impression: Impression)
    func manager(_ manager: BannerViewManager, didRecordClick impression: Impression)
    func manager(_ manager: BannerViewManager, willPresentModalView impression: Impression)
    func manager(_ manager: BannerViewManager, didDismissModalView impression: Impression)
    func manager(_ manager: BannerViewManager, willLeaveApplication impression: Impression)
}


final internal class BannerViewManager: NSObject {
    static var impressionKey: UInt8 = 0

    fileprivate struct AdViewImpression: Impression {
        var impressionId: String = UUID().uuidString
        var auctionId: String
        var auctionConfigurationId: Int
        var ad: Ad
        
        init(
            auctionId: String,
            auctionConfigurationId: Int,
            ad: Ad
        ) {
            self.auctionId = auctionId
            self.auctionConfigurationId = auctionConfigurationId
            self.ad = ad
        }
    }
    
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
        let timer = Timer.scheduledTimer(
            withTimeInterval: interval,
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
        size: CGSize
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
                view.widthAnchor.constraint(equalToConstant: size.width),
                view.heightAnchor.constraint(equalToConstant: size.height)
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
            ad: demand.ad
        )
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTap))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    
    @objc private
    func didReceiveTap(_ recognizer: UITapGestureRecognizer) {
        guard
            let adView = recognizer.view as? AdViewContainer,
            let impression = adView.impression
        else { return }
        
        delegate?.manager(self, didRecordClick: impression)
    }
    
    private func trackImpression(adView: AdViewContainer) {
        guard let impression = adView.impression else { return }
        delegate?.manager(self, didRecordImpression: impression)
    }
}


extension BannerViewManager: DemandProviderAdViewDelegate {
    func providerWillPresentModalView(
        _ provider: AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.manager(self, willPresentModalView: impression)
    }
    
    func providerDidDismissModalView(
        _ provider: AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.manager(self, didDismissModalView: impression)
    }
    
    func providerWillLeaveApplication(
        _ provider: AdViewDemandProvider,
        adView: AdViewContainer
    ) {
        guard let impression = adView.impression else { return }
        delegate?.manager(self, willLeaveApplication: impression)
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
    var impression: Impression? {
        get { objc_getAssociatedObject(self, &BannerViewManager.impressionKey) as? Impression }
        set { objc_setAssociatedObject(self, &BannerViewManager.impressionKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func destroy() {
        impression = nil
        removeFromSuperview()
    }
}
