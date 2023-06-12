//
//  AdViewImpressionRequestBuilder.swift
//  Bidon
//
//  Created by Stas Kochkin on 02.06.2023.
//

import Foundation


final class AdViewImpressionRequestBuilder: BaseImpressionRequestBuilder<AdViewAucionContext> {
    override var adType: AdType { .banner }
    
    override var imp: ImpressionModel {
        ImpressionModel(
            impression,
            banner: AdViewAucionContextModel(context)
        )
    }
}