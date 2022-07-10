//
//  AdContainerView.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import UIKit


@objc open class AdContainerView: UIView {
    private lazy var manager: AdContainerViewManager = {
        let manager = AdContainerViewManager()
        manager.container = self
        return manager
    }()
    
    final override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard !manager.isAdPresented else { return }
        fetch { [weak self] adView in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            self.layout(adView: adView)
        }
    }
    
    open func fetch(_ completion: @escaping (UIView?) -> ()) {}
    
    final func layout(adView: UIView) {
        DispatchQueue.main.async { [weak self, weak adView] in
            guard
                let self = self,
                let adView = adView
            else { return }
            
            self.manager.layout(view: adView)
        }
    }
}
