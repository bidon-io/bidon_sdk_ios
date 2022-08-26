//
//  InterstitialImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation
import UIKit



class InterstitialImpressionController: NSObject, FullscreenImpressionController {
    typealias Context = UIViewController
    
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    let provider: InterstitialDemandProvider
    let ad: Ad
    
    required init(demand: Demand) throws {
        guard let provider = demand.provider as? InterstitialDemandProvider else {
            throw SdkError.internalInconsistency
        }
        
        self.provider = provider
        self.ad = demand.ad
        
        super.init()
        
        provider.delegate = self
    }
    
    func show(from context: UIViewController) {
        provider.show(ad: ad, from: context)
    }
}


extension InterstitialImpressionController: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        
    }
}
