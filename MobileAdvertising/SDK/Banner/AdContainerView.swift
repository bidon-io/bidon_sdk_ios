//
//  AdContainerView.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit


@objc open class AdContainerView: UIView {
    @objc public final var autorefreshInterval: TimeInterval = 5 {
        didSet { scheduleRefreshIfNeeded() }
    }
    
    @objc public final var isAutorefreshing: Bool = true {
        didSet {
            isAutorefreshing ?
            scheduleRefreshIfNeeded() :
            manager.cancelRefreshTimer()
        }
    }
    
    private lazy var manager: AdContainerViewManager = {
        let manager = AdContainerViewManager()
        manager.container = self
        return manager
    }()
    
    final override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard !manager.isAdPresented else { return }
        refresh()
    }
    
    open func fetch(_ completion: @escaping (UIView?) -> ()) {}
    open func loadAd() {}
    
    final func layout(adView: UIView) {
        DispatchQueue.main.async { [weak self, weak adView] in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            self.manager.layout(view: adView)
            self.scheduleRefreshIfNeeded()
        }
    }
    
    private final func refresh() {
        fetch { [weak self] adView in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            self.layout(adView: adView)
        }
    }
    
    private final func scheduleRefreshIfNeeded() {
        guard isAutorefreshing, autorefreshInterval > 0, manager.isRefreshGranted
        else { return }
        weak var weakSelf = self
        loadAd()
        manager.schedule(autorefreshInterval, block: weakSelf?.refresh)
    }
}
