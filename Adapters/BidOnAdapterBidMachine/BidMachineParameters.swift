//
//  BidMachineParameters.swift
//  BidMachineAdapter
//
//  Created by Stas Kochkin on 07.07.2022.
//

import Foundation


public struct BidMachineParameters: Codable {
    public var sellerId: String
    
    public init(sellerId: String) {
        self.sellerId = sellerId
    }
}
