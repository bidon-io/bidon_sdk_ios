//
//  BidMachineAdapter.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation
import BidMachine
import MobileAdvertising


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class BidMachineDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public let id: String = "bidmachine"
    
    public let parameters: BidMachineParameters
    
    public init(parameters: BidMachineParameters) {
        self.parameters = parameters
        super.init()
    }
    
    public func interstitial() throws -> InterstitialDemandProvider {
        return BidMachineInterstitialDemandProvider()
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        return BidMachineRewardedAdDemandProvider()
    }
    
    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
        return BidMachineBannerDemandProvider(context: context)
    }
}


extension BidMachineDemandSourceAdapter: ParameterizedAdapter {
    public typealias Parameters = BidMachineParameters
    
    @objc public convenience init(rawParameters: Data) throws {
        let parameters = try JSONDecoder().decode(
            BidMachineParameters.self,
            from: rawParameters
        )
        self.init(parameters: parameters)
    }
}


extension BidMachineDemandSourceAdapter: InitializableAdapter {
    public func initilize(
        _ completion: @escaping (Error?) -> ()
    ) {
        let configuration = BDMSdkConfiguration()
        configuration.testMode = true
        
        BDMSdk.shared().startSession(
            withSellerID: parameters.sellerId,
            configuration: configuration
        ) {
            completion(nil)
        }
    }
}


internal extension Price {
    var bdm: BDMPriceFloor {
        let pricefloor = BDMPriceFloor()
        pricefloor.value = NSDecimalNumber(
            decimal: Decimal(isUnknown ? 0.01 : self)
        )
        return pricefloor
    }
}







