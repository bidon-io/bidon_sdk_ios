//
//  BannerViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator
import AppLovinSDK
import SwiftUI


final class BannerViewModel: AdViewModel {
    private let eventPassthroughSubject = PassthroughSubject<AdEventModel, Never>()
    
    @Published var adFormat: MAAdFormat = UIDevice.current.userInterfaceIdiom == .pad ? .leader : .banner
    @Published var isAutorefresh: Bool = true
    @Published var autorefreshInterval: TimeInterval = 5
    @Published var isAdaptive: Bool = true
    
    var bannerHieght: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50
    }

    override init() {
        super.init()
        subscribe(eventPassthroughSubject.eraseToAnyPublisher())
    }
    
    func send(_ event: AdEventModel) {
        eventPassthroughSubject.send(event)
    }
}
