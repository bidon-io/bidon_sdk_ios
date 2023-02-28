//
//  AppLovinRewardWrapper.swift
//  BidOnAdapterAppLovin
//
//  Created by Stas Kochkin on 27.02.2023.
//

import Foundation
import BidOn


typealias AppLovinRewardWrapper = RewardWrapper<[AnyHashable: Any]>

extension AppLovinRewardWrapper {
    convenience init(_ response: [AnyHashable : Any]) {
        let label = (response["currency"] as? String) ?? ""
        let amount = (response["amount"] as? Int) ?? .zero
        
        self.init(
            label: label,
            amount: amount,
            wrapped: response
        )
    }
}
