//
//  AdContainerView.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit


@objc(BDAdContainerView)
open class AdContainerView: UIView {
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard !manager.isAdPresented else { return }
        refresh()
    }
    
    open func fetch(_ completion: @escaping (AdViewContainer?) -> ()) {}
    open func loadAd() {}
    open func preferredSize() -> CGSize { .zero }
    
    final func layout(adView: AdViewContainer) {
        DispatchQueue.main.async { [weak self, weak adView] in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            Logger.verbose("Banner \(self) did layout ad view \(adView), size: \(self.preferredSize())")
            self.manager.layout(view: adView, size: self.preferredSize())
            self.scheduleRefreshIfNeeded()
        }
    }
    
    private final func refresh() {
        Logger.verbose("Banner \(self) will refresh ad view")
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
        Logger.verbose("Banner \(self) did start refresh timer with interval: \(autorefreshInterval)s")
        loadAd()
        manager.schedule(autorefreshInterval, block: weakSelf?.refresh)
    }
}
