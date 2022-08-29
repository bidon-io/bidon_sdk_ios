//
//  BannerViewModel.swift
//  Sandbox
//
//  Created by Stas Kochkin on 29.08.2022.
//

import Foundation
import Combine
import BidOn


final class BannerAdSectionViewModel: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var format: AdViewFormat = .banner
    @Published var isAutorefreshing: Bool = true
    @Published var autorefreshInterval: TimeInterval = 15
}
