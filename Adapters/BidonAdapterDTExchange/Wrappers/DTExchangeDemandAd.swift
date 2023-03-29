//
//  DTExchangeAdWrapper.swift
//  BidonAdapterDTExchange
//
//  Created by Bidon Team on 27.02.2023.
//

import Foundation
import Bidon
import IASDKCore


protocol DTExchangeDemandAd: DemandAd {}


extension IAAdSpot: DemandAd {
    public var id: String { adRequest.unitID ?? UUID().uuidString }
    public var networkName: String { DTExchangeDemandSourceAdapter.identifier }
    public var dsp: String? { nil }
}
