//
//  AdProtocol.swift
//  MobileAdvertising
//
//  Created by Bidon Team on 04.07.2022.
//

import Foundation


@objc(BDNAd)
public protocol Ad {
    var id: String { get }
    var eCPM: Price { get }
    var adUnitId: String? { get }
    var networkName: String { get }
    var dsp: String? { get }
}


public final class AdWrapper<Wrapped: AnyObject>: Ad {
    public let id: String
    public let eCPM: Price
    public let networkName: String
    public let dsp: String?
    public let adUnitId: String?
    public let wrapped: Wrapped

    public init(
        id: String,
        eCPM: Price,
        networkName: String,
        dsp: String? = nil,
        adUnitId: String? = nil,
        wrapped: Wrapped
    ) {
        self.id = id
        self.eCPM = eCPM
        self.networkName = networkName
        self.dsp = dsp
        self.adUnitId = adUnitId
        self.wrapped = wrapped
    }
    
    convenience public init(
        id: String,
        networkName: String,
        dsp: String? = nil,
        lineItem: LineItem,
        wrapped: Wrapped
    ) {
        self.init(
            id: id,
            eCPM: lineItem.pricefloor,
            networkName: networkName,
            dsp: dsp,
            adUnitId: lineItem.adUnitId,
            wrapped: wrapped
        )
    }
}


fileprivate extension Formatter {
    static let eCPM: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}


extension AdWrapper: CustomStringConvertible {
    public var description: String {
        let components: [String?] = [
            "ad #\(id)",
            Formatter.eCPM.string(from: eCPM as NSNumber).map { "eCPM \($0)" },
            "network '\(networkName)'",
            dsp.map { "DSP '\($0)'" },
            adUnitId.map { "ad unit id \($0)" }
        ]
        
        return components
            .compactMap { $0 }
            .joined(separator: ", ")
            .capitalized
    }
}


