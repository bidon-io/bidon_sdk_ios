//
//  AdapterProtocol.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 15.06.2022.
//

import Foundation


@objc public protocol Adapter {
    var id: String { get }
}


public protocol InitializableAdapter: Adapter {
    @available(iOS 13.0.0, *)
    func initialize() async throws
    
    func initilize(_ completion: @escaping (Error?) -> ())
}


public protocol ParameterizedAdapter: Adapter {
    associatedtype Parameters
    
    var parameters: Parameters { get }
    
    init(parameters: Parameters)
}

