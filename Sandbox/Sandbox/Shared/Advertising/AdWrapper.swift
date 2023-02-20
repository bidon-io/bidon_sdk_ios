//
//  AppodealAdWrapper.swift
//  Sandbox
//
//  Created by Stas Kochkin on 15.02.2023.
//

import Foundation
import Combine
import SwiftUI
import Appodeal
import BidOn


protocol AdWrapper {
    var adEventSubject: PassthroughSubject<AdEventModel, Never> { get }
    var adType: AdType { get }
}


protocol FullscreenAdWrapper: AdWrapper {
    func show() async throws
    func load(pricefloor: Double) async throws
}


extension AdWrapper {
    func send(
        event title: String,
        detail: String,
        bage: String,
        color: Color
    ) {
        let adEvent = AdEventModel(
            date: Date(),
            adType: .interstitial,
            title: title,
            subtitle: detail,
            bage: bage,
            color: color
        )
        
        adEventSubject.send(adEvent)
    }
}
