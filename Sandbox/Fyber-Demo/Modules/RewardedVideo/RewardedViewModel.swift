//
//  RewardedViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import FyberDecorator
import FairBidSDK
import SwiftUI


final class RewardedViewModel: AdViewModel {
    @Published var placement: String = "197406"
    
    func load() {
        BNFYBRewarded.request(placement)
    }
    
    func present() {
        BNFYBRewarded.show(placement)
    }
}
