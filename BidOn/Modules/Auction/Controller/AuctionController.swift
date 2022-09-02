//
//  AuctionControllerDelegate.swift
//  MobileAdvertising
//
//  Created by Stas Kochkin on 06.07.2022.
//

import Foundation


protocol AuctionController {    
    var id: String { get }
    var delegate: AuctionControllerDelegate? { get }
    
    func load()
}


protocol AuctionControllerDelegate: AnyObject {
    func controllerDidStartAuction(_ controller: AuctionController)

    func controller(
        _ controller: AuctionController,
        didStartRound round: AuctionRound,
        pricefloor: Price
    )

    func controller(
        _ controller: AuctionController,
        didReceiveAd ad: Ad,
        provider: DemandProvider
    )

    func controller(
        _ controller: AuctionController,
        didCompleteRound round: AuctionRound
    )

    func controller(
        _ controller: AuctionController,
        completeAuction winner: Ad
    )

    func controller(
        _ controller: AuctionController,
        failedAuction error: Error
    )
}
