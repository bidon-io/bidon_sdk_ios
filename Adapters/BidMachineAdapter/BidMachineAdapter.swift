//
//  BidMachineAdapter.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 29.06.2022.
//

import Foundation
import BidMachine
import MobileAdvertising


internal typealias DemandSourceAdapter = InterstitialDemandSourceAdapter


public struct BidMachineAdapterParameters: Codable {
    public var sellerId: String
    
    public init(sellerId: String) {
        self.sellerId = sellerId
    }
}


@objc public final class BidMachineAdapter: NSObject, DemandSourceAdapter {
    @objc public let id: String = "bidmachine"
    
    public let parameters: BidMachineAdapterParameters
    
    public init(parameters: BidMachineAdapterParameters) {
        self.parameters = parameters
        super.init()
    }
    
    public func interstitial() throws -> InterstitialDemandProvider {
        return BidMachineInterstitialDemandProvider()
    }
}


extension BidMachineAdapter: ParameterizedAdapter {
    public typealias Parameters = BidMachineAdapterParameters
    
    @objc public convenience init(rawParameters: Data) throws {
        let parameters = try JSONDecoder().decode(
            BidMachineAdapterParameters.self,
            from: rawParameters
        )
        self.init(parameters: parameters)
    }
}


extension BidMachineAdapter: InitializableAdapter {
    @available(iOS 13, *)
    public func initialize() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            initilize { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
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







