//
//  MRECViewModel.swift
//  AppLovinMAX-Demo
//
//  Created by Stas Kochkin on 08.07.2022.
//

import Foundation
import Combine
import AppLovinDecorator
import AppLovinSDK
import SwiftUI


final class MRECViewModel: AdViewModel {
    private let eventPassthroughSubject = PassthroughSubject<AdEvent, Never>()
    
    @Published var adFormat: MAAdFormat = .mrec
    @Published var isAutorefresh: Bool = true
    @Published var autorefreshInterval: TimeInterval = 5
    
    override init() {
        super.init()
        subscribe(eventPassthroughSubject.eraseToAnyPublisher())
    }
    
    func send(_ event: AdEvent) {
        eventPassthroughSubject.send(event)
    }
}
