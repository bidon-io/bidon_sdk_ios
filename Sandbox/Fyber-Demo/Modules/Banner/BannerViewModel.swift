//
//  BannerViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import BidOnDecoratorFyber
import FairBidSDK
import SwiftUI


final class BannerViewModel: AdViewModel {
    @Published var placement: String = "197407"
    @Published var isPresented: Bool = false
    
    @Published var isAdaptiveSize: Bool = BNFYBBanner.isAdaptiveSize {
        didSet { BNFYBBanner.isAdaptiveSize = isAdaptiveSize }
    }
    
    @Published var isAutorefreshing: Bool = BNFYBBanner.isAutorefreshing {
        didSet { BNFYBBanner.isAutorefreshing = isAutorefreshing }
    }
    
    @Published var autorefreshInterval: TimeInterval = BNFYBBanner.autorefreshInterval {
        didSet { BNFYBBanner.autorefreshInterval = autorefreshInterval }
    }
}
