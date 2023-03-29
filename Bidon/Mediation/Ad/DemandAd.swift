//
//  DemandAd.swift
//  Bidon
//
//  Created by Stas Kochkin on 28.03.2023.
//

import Foundation


@objc
public protocol DemandAd {
    @objc var id: String { get }
    @objc var networkName: String { get }
    @objc var dsp: String? { get }
    
    @objc optional
    var eCPM: Price { get }
    
    @objc optional
    var currency: Currency { get }
}
