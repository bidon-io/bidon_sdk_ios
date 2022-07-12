//
//  ContentViewModel.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 10.07.2022.
//

import Foundation
import IronSource
import IronSourceDecorator
import MobileAdvertising
import Combine
import SwiftUI


final class HomeViewModel: ObservableObject {
    @Published var events: [AdEventModel] = []

    private var controller: UIViewController! { UIApplication.shared.topViewContoller }
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.MergeMany([
            IronSource.bid.rewardedVideoDelelegatePublisher
        ])
        .receive(on: DispatchQueue.main)
        .sink { event in
            withAnimation { [weak self] in
                self?.events.append(event)
            }
        }
        .store(in: &cancellables)
    }
    
    func showRewardedVideo() {
        IronSource.bid.showRewardedVideo(with: controller)
    }
    
    func showInterstitial() {
        IronSource.bid.showInterstitial(with: controller)
    }
}
