//
//  BannerViewModel.swift
//  Sandbox
//
//  Created by Bidon Team on 29.08.2022.
//

import Foundation
import Combine
import Bidon
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
    @Published var ad: Bidon.Ad?
    
    func receive(event: AdEventModel) {
        withAnimation { [unowned self] in
            self.events.append(event)
        }
    }
    
    func notify(loss ad: Ad) {
        
    }
}
