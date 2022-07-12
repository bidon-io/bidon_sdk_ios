//
//  InterstitialViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 05.07.2022.
//

import Foundation
import Combine
import FyberDecorator
import FairBidSDK
import SwiftUI


final class InterstitialViewModel: AdViewModel {
    @Published var placement: String = "197405"
    
    func load() {
        BNFYBInterstitial.request(placement)
    }
    
    func present() {
        BNFYBInterstitial.show(placement)
    }
}
