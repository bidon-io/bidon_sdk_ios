//
//  FullscreenImpressionController.swift
//  Bidon
//
//  Created by Bidon Team on 25.08.2022.
//

import Foundation
import UIKit


protocol FullscreenImpressionControllerDelegate: AnyObject {
    func willPresent(_ impression: inout Impression)
    
    func didHide(_ impression: inout Impression)
    
    func didClick(_ impression: inout Impression)
    
    func didFailToPresent(_ impression: inout Impression?, error: SdkError)
    
    func didReceiveReward(_ reward: Reward, impression: inout Impression)
}


protocol FullscreenImpressionController: AnyObject {
    associatedtype DemandType: Demand
    
    init(demand: DemandType)
    
    func show(from rootViewController: UIViewController)
    
    var delegate: FullscreenImpressionControllerDelegate? { get set }
}


struct FullscreenImpression: Impression {
    var impressionId: String = UUID().uuidString
    var showTrackedAt: TimeInterval = .nan
    var clickTrackedAt: TimeInterval = .nan
    var rewardTrackedAt: TimeInterval = .nan
    var auctionId: String
    var auctionConfigurationId: Int
    var ad: Ad
    
    init<T: Demand>(demand: T) {
        self.auctionId = demand.auctionId
        self.auctionConfigurationId = demand.auctionConfigurationId
        self.ad = demand.ad
    }
}
