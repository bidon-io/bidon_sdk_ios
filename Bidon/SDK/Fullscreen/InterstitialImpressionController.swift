//
//  InterstitialImpressionController.swift
//  Bidon
//
//  Created by Bidon Team on 16.08.2022.
//

import Foundation
import UIKit



final class InterstitialImpressionController: NSObject, FullscreenImpressionController {
    typealias Context = UIViewController
    
    weak var delegate: FullscreenImpressionControllerDelegate?
    
    private let provider: any InterstitialDemandProvider
    private var impression: Impression!
    
    required init(demand: AnyInterstitialDemand) {
        let demand = demand.unwrapped()
        
        self.provider = demand.provider
        self.impression = FullscreenImpression(demand: demand)
        
        super.init()
        
        provider.delegate = self
    }
    
    func show(from context: UIViewController) {
        provider._show(ad: impression.ad, from: context)
    }
}


extension InterstitialImpressionController: DemandProviderDelegate {
    func providerWillPresent(_ provider: any DemandProvider) {
        delegate?.willPresent(&impression)
    }
    
    func providerDidHide(_ provider: any DemandProvider) {
        delegate?.didHide(&impression)
    }
    
    func providerDidClick(_ provider: any DemandProvider) {
        delegate?.didClick(&impression)
    }
    
    func providerDidFailToDisplay(_ provider: any DemandProvider, error: SdkError) {
        delegate?.didFailToPresent(&impression, error: error)
    }
}
