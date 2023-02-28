//
//  DTExchangeDemandSourceAdapter.swift
//  BidOnAdapterDTExchange
//
//  Created by Stas Kochkin on 27.02.2023.
//

import Foundation
import IASDKCore
import BidOn


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter & RewardedAdDemandSourceAdapter & AdViewDemandSourceAdapter


@objc public final class DTExchangeDemandSourceAdapter: NSObject, DemandSourceAdapter {
    @objc public static let identifier = "dt_exchange"
    
    public let identifier: String = DTExchangeDemandSourceAdapter.identifier
    public let name: String = "DT Exchange"
    public let adapterVersion: String = "1"
    public let sdkVersion: String = IASDKCore.sharedInstance().version()
    
    public func interstitial() throws -> InterstitialDemandProvider {
        return DTExchangeInterstitialDemandProvider()
    }
    
    public func rewardedAd() throws -> RewardedAdDemandProvider {
        return DTExchangeInterstitialDemandProvider()
    }
    
    public func adView(_ context: AdViewContext) throws -> AdViewDemandProvider {
        return DTExchangeBannerDemandProvider()
    }
}


extension DTExchangeDemandSourceAdapter: InitializableAdapter {
    private struct Parameters: Codable {
        public var appId: String
    }
    
    public func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    ) {

        var parameters: Parameters?
            
        do {
            parameters = try Parameters(from: decoder)
        } catch {
            completion(.failure(SdkError(error)))
        }
        
        guard let parameters = parameters else { return }
              
        IASDKCore.sharedInstance().mediationType = nil
        IASDKCore.sharedInstance().keywords = "hell & brimstone + earthly/delight, diving,programming\new line"
        
        IASDKCore.sharedInstance().initWithAppID(
            parameters.appId,
            completionBlock: { isSuccess, error in
                if isSuccess {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(.generic(error: error)))
                } else {
                    completion(.failure(.unknown))
                }
            },
            completionQueue: nil
        )
    }
}
