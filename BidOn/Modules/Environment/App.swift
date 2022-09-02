//
//  App.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


protocol App {
    var bundle: String { get }
    var version: String { get }
    var key: String { get }
    var framework: String { get }
    var frameworkVersion: String? { get }
    var pluginVersion: String? { get }
}
