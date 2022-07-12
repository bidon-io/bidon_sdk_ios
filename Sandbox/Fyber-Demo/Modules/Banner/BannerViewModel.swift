//
//  BannerViewModel.swift
//  Fyber-Demo
//
//  Created by Stas Kochkin on 12.07.2022.
//

import Foundation
import FyberDecorator
import FairBidSDK
import SwiftUI


final class BannerViewModel: AdViewModel {
    @Published var placement: String = "197407"
    @Published var isPresented: Bool = false
}
