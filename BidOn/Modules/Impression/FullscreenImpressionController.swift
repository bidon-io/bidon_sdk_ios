//
//  FullscreenImpressionController.swift
//  BidOn
//
//  Created by Stas Kochkin on 25.08.2022.
//

import Foundation


protocol FullscreenImpressionControllerDelegate: AnyObject {
    func didPresent(_ ad: Ad)
    
    func didHide(_ ad: Ad)
    
    func didClick(_ ad: Ad)
    
    func didFailToPresent(_ ad: Ad?, error: Error)
    
    func didReceiveReward(_ reward: Reward, ad: Ad)
}


protocol FullscreenImpressionController: ImpressionController {
    var delegate: FullscreenImpressionControllerDelegate? { get set }
}
