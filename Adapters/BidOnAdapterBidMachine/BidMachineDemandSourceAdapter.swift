//
//  BidMachineAdapter.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation
import BidMachine
import BidOn


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class BidMachineDemandSourceAdapter: NSObject, DemandSourceAdapter {
    public let identifier: String = "bidmachine"
    public let name: String = "BidMachine"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = kBDMVersion
    
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







