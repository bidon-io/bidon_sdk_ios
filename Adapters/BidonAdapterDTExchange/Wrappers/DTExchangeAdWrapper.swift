//
//  DTExchangeAdWrapper.swift
//  BidonAdapterDTExchange
//
//  Created by Bidon Team on 27.02.2023.
//

import Foundation
import Bidon
import IASDKCore


final class DTExchangeAdWrapper: NSObject, Ad {
    var id: String { lineItem.adUnitId }
    var eCPM: Bidon.Price { lineItem.pricefloor }
    var adUnitId: String? { lineItem.adUnitId }
    var networkName: String { DTExchangeDemandSourceAdapter.identifier }
    var dsp: String? { nil }
    
    let lineItem: LineItem
    let adSpot: IAAdSpot
    
    init(
        lineItem: LineItem,
        adSpot: IAAdSpot
    ) {
        self.lineItem = lineItem
        self.adSpot = adSpot
    }
}
