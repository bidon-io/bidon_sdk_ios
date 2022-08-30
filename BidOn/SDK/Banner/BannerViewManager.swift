//
//  AdContainerViewManager.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit



protocol BannerViewManagerDelegate: AnyObject {
    func manager(_ manager: BannerViewManager, didRecordImpression: Impression)
    func manager(_ manager: BannerViewManager, didRecordClick impression: Impression)
}


final internal class BannerViewManager {
    weak var container: UIView?
    
    private var timer: Timer?
    
    var isAdPresented: Bool {
        guard let container = container else { return false }
        return !container.subviews.isEmpty
    }
    
    weak var delegate: BannerAdManagerDelegate?
    
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
    
    func layout(
        view: AdViewContainer,
        provider: AdViewDemandProvider,
        size: CGSize
    ) {
        guard
            let container = container,
            !container.subviews.contains(view)
        else { return }
        
        provider.adViewDelegate = self
        
        let viewsToRemove = container.subviews
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
            }) { _ in
                viewsToRemove.forEach { $0.removeFromSuperview() }
            }
    }
}


extension BannerViewManager: DemandProviderAdViewDelegate {
    func provider(_ provider: AdViewDemandProvider, willPresentModalView ad: Ad) {
        
    }
    
    func provider(_ provider: AdViewDemandProvider, didDismissModalView ad: Ad) {
        
    }
    
    func provider(_ provider: AdViewDemandProvider, willLeaveApplication ad: Ad) {
        
    }
}
