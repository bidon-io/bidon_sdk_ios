//
//  AdViewFormat+Banner.swift
//  FyberDecorator
//
//  Created by Stas Kochkin on 13.07.2022.
//

import Foundation
import UIKit
import BidOn


internal extension AdViewFormat {
    static var `default`: AdViewFormat {
        return UIDevice.current.userInterfaceIdiom == .phone ? .banner : .leaderboard
    }
}
