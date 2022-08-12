//
//  AdapterProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
//

import Foundation


@objc public protocol Adapter {
    var identifier: String { get }
    var name: String { get }
    var version: String { get }
    var sdkVersion: String { get }
    
    init()
}


public protocol ParametersEncodableAdapter: Adapter {
    func encodeAdapterParameters(to encoder: Encoder) throws
}


public protocol InitializableAdapter: Adapter {
    func initialize(
        from decoder: Decoder,
        completion: @escaping (Result<Void, SdkError>) -> Void
    )
}


//public protocol AdapterInfoProvider: Adapter  {
//    func encode(_ container: inout KeyedEncodingContainer<DynamicCodingKey>) throws
//}


//public protocol InitializableAdapter: Adapter {
//    func initilize(_ completion: @escaping (Error?) -> ())
//}
//
//
//extension InitializableAdapter {
//    @available(iOS 13, *)
//    public func initialize() async throws {
//        return try await withCheckedThrowingContinuation { continuation in
//            initilize { error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else {
//                    continuation.resume()
//                }
//            }
//        }
//    }
//}

