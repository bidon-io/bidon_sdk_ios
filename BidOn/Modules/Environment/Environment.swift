//
//  Environment.swift
//  BidOn
//
//  Created by Stas Kochkin on 05.08.2022.
//

import Foundation


enum EnvironmentType: String {
    case device
    case session
    case app
    case user
    case geo
}


protocol Environment {}
