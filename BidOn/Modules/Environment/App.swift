//
//  App.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation

#warning("Fill in all required fields")
protocol App: Environment {
    var bundle: String { get }
    var key: String { get }
}
