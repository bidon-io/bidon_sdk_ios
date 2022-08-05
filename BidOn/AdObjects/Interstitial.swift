//
//  Interstitial.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation


@objc(BDInterstitial)
public final class Interstitial: NSObject {
    @objc public let placement: String
    
    @objc public init(placement: String) {
        self.placement = placement
        super.init()
    }
    
    @objc public func loadAd() {
        
    }
}
