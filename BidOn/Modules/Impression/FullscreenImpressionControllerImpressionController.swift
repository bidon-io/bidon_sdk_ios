//
//  InterstitialImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 16.08.2022.
//

import Foundation
import UIKit


protocol FullscreenImpressionControllerDelegate: AnyObject {
    func controller(_ controller: FullscreenImpressionController, didPresent ad: Ad)
    func controller(_ controller: FullscreenImpressionController, didHide ad: Ad)
    func controller(_ controller: FullscreenImpressionController, didClick ad: Ad)
    func controller(_ controller: FullscreenImpressionController, didFailToDisplay ad: Ad, error: Error)
}


final class FullscreenImpressionController: NSObject, ImpressionController {
    typealias Context = UIViewController
    
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    let provider: InterstitialDemandProvider
    let ad: Ad
    
    init(demand: Demand) throws {
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


extension FullscreenImpressionController: DemandProviderDelegate {
    func provider(_ provider: DemandProvider, didPresent ad: Ad) {
        delegate?.controller(self, didPresent: ad)
    }
    
    func provider(_ provider: DemandProvider, didHide ad: Ad) {
        delegate?.controller(self, didHide: ad)
    }
    
    func provider(_ provider: DemandProvider, didClick ad: Ad) {
        delegate?.controller(self, didClick: ad)
    }
    
    func provider(_ provider: DemandProvider, didFailToDisplay ad: Ad, error: Error) {
        delegate?.controller(self, didFailToDisplay: ad, error: error)
    }
}
