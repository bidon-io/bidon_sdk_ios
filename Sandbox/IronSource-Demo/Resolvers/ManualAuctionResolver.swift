//
//  ManualAuctionResolver.swift
//  IronSource-Demo
//
//  Created by Stas Kochkin on 14.07.2022.
//

import Foundation
import UIKit
import MobileAdvertising


final class ManualAuctionResolver: AuctionResolver {
    func resolve(ads: [Ad], resolution: @escaping (Ad?) -> ()) {
        guard let controller = UIApplication.shared.topViewContoller, !ads.isEmpty else {
            resolution(nil)
            return
        }
        
        let alert = UIAlertController(
            title: "Find winner ad",
            message: "Select one of following ad:",
            preferredStyle: .actionSheet
        )
        
        ads.forEach { ad in
            let action = UIAlertAction(title: ad.text, style: .default) { _ in
                resolution(ad)
            }
            alert.addAction(action)
        }
        
        controller.present(alert, animated: true)
    }
}
