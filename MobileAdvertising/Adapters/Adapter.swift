//
//  AdapterProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
//

import Foundation


@objc public protocol Adapter {
    var identifier: String { get }
}


public protocol InitializableAdapter: Adapter {
    func initilize(_ completion: @escaping (Error?) -> ())
}


extension InitializableAdapter {
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
}


public protocol ParameterizedAdapter: Adapter {
    associatedtype Parameters
    
    var parameters: Parameters { get }
    
    init(parameters: Parameters)
}

