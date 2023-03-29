//
//  GoogleMobileAd.swift
//  BidonAdapterGoogleMobileAds
//
//  Created by Bidon Team on 30.08.2022.
//

import Foundation
import GoogleMobileAds
import Bidon


protocol GoogleMobileAdsDemandAd: DemandAd {
    var paidEventHandler: GADPaidEventHandler? { get set }
}


extension GADInterstitialAd: GoogleMobileAdsDemandAd {
    public var id: String { responseInfo.responseIdentifier ?? UUID().uuidString }
    public var dsp: String? { nil }
    public var networkName: String { GoogleMobileAdsDemandSourceAdapter.identifier }
}


extension GADRewardedAd: GoogleMobileAdsDemandAd {
    public var id: String { responseInfo.responseIdentifier ?? UUID().uuidString }
    public var dsp: String? { nil }
    public var networkName: String { GoogleMobileAdsDemandSourceAdapter.identifier }
}


extension GADBannerView: GoogleMobileAdsDemandAd {
    public var id: String { responseInfo?.responseIdentifier ?? UUID().uuidString }
    public var dsp: String? { nil }
    public var networkName: String { GoogleMobileAdsDemandSourceAdapter.identifier }
}
