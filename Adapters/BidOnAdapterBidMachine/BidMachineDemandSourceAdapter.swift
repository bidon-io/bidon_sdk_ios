//
//  BidMachineAdapter.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation
import BidMachine
import BidOn


internal typealias DemandSourceAdapter = Adapter//InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class BidMachineDemandSourceAdapter: NSObject, DemandSourceAdapter {
    public let identifier: String = "bidmachine"
    public let name: String = "BidMachine"
    public let version: String = "1"
    public let sdkVersion: String = kBDMVersion
    
//    public func interstitial() throws -> InterstitialDemandProvider {
////        return BidMachineInterstitialDemandProvider()
//    }
//
//    public func rewardedAd() throws -> RewardedAdDemandProvider {
////        return BidMachineRewardedAdDemandProvider()
//    }
//
//    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
////        return BidMachineBannerDemandProvider(context: context)
//    }
}


//extension BidMachineDemandSourceAdapter: ParameterizedAdapter {
//    public typealias Parameters = BidMachineParameters
//
//    @objc public convenience init(rawParameters: Data) throws {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        let parameters = try decoder.decode(
//            BidMachineParameters.self,
//            from: rawParameters
//        )
//
//        self.init(parameters: parameters)
//    }
//}
//
//
extension BidMachineDemandSourceAdapter: InitializableAdapter {
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        guard !BDMSdk.shared().isInitialized else {
            completion(.failure(SdkError.internalInconsistency))
            return
        }
        
        var parameters: BidMachineParameters?
        
        do {
           parameters = try BidMachineParameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        guard let parameters = parameters else { return }

        
        let configuration = BDMSdkConfiguration()
#if DEBUG
        configuration.testMode = true
#endif
        
        BDMSdk.shared().enableLogging = Logger.level == .verbose
        BDMSdk.shared().startSession(
            withSellerID: parameters.sellerId,
            configuration: configuration
        ) {
            completion(.success(()))
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







