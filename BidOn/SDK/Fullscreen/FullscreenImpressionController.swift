//
//  FullscreenImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation
import UIKit


protocol FullscreenImpressionControllerDelegate: AnyObject {
    func willPresent(_ impression: Impression)
    
    func didHide(_ impression: Impression)
    
    func didClick(_ impression: Impression)
    
    func didFailToPresent(_ impression: Impression?, error: Error)
    
    func didReceiveReward(_ reward: Reward, impression: Impression)
}


protocol FullscreenImpressionController: AnyObject {
    init(demand: Demand) throws
    
    func show(from rootViewController: UIViewController)
    
    var delegate: FullscreenImpressionControllerDelegate? { get set }
}


struct FullscreenImpression: Impression {
    var impressionId: String = UUID().uuidString
    
    var auctionId: String
    var auctionConfigurationId: Int
    var ad: Ad
    
    init(demand: Demand) {
        self.auctionId = demand.auctionId
        self.auctionConfigurationId = demand.auctionConfigurationId
        self.ad = demand.ad
    }
}
