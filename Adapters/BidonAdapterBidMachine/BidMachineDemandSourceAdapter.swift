//
//  BidMachineAdapter.swift
//  BidMachineAdapter
//
//  Created by Bidon Team on 29.06.2022.
//

import Foundation
import BidMachine
import Bidon


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class BidMachineDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc static let identifier = "bidmachine"
    
    @Injected(\.context)
    var context: Bidon.AuctionContext
    
    public let identifier: String = BidMachineDemandSourceAdapter.identifier
    public let name: String = "BidMachine"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = BidMachineSdk.sdkVersion
    
    public func interstitial() throws -> any InterstitialDemandProvider {
        return BidMachineInterstitialDemandProvider()
    }
    
    public func rewardedAd() throws -> any RewardedAdDemandProvider {
        BidMachineRewardedAdDemandProvider()
    }
    
    public func adView(_ context: AdViewContext) throws -> any AdViewDemandProvider {
        BidMachineAdViewDemandProvider()
    }
}


extension BidMachineDemandSourceAdapter: InitializableAdapter {
    private struct Parameters: Codable {
        var sellerId: String
    }
    
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {
        guard !BidMachineSdk.shared.isInitialized else {
            completion(.failure(SdkError.internalInconsistency))
            return
        }
        
        var parameters: Parameters?
        
        do {
            parameters = try Parameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        guard let parameters = parameters else { return }
        
        BidMachineSdk.shared.populate { builder in
            builder.withLoggingMode(Logger.level == .verbose)
            builder.withTestMode(context.isTestMode)
        }
        
        BidMachineSdk.shared.initializeSdk(parameters.sellerId)
        completion(.success(()))
    }
}







