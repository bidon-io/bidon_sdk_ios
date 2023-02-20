//
//  BannerViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import Combine
import BidOn
import AppsFlyerAdRevenue
import SwiftUI


final class BannerAdSectionViewModel: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var format: AdBannerWrapperFormat = .adaptive
    @Published var isAutorefreshing: Bool = false
    @Published var autorefreshInterval: TimeInterval = 15
    @Published var events: [AdEventModel] = []
    @Published var isLoading: Bool = false
    @Published var pricefloor: Price = 0.1
    
    func receive(_ event: AdEventModel) {
        withAnimation { [unowned self] in
            self.events.append(event)
        }
    }
}
