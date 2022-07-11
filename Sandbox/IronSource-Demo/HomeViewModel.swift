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


final class HomeViewModel: ObservableObject {
    private var controller: UIViewController! { UIApplication.shared.topViewContoller }
    
    func showRewardedVideo() {
        IronSource.bid.showRewardedVideo(with: controller)
    }
    
    func showInterstitial() {
        IronSource.bid.showInterstitial(with: controller)
    }
}
