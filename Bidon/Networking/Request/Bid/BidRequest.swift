//
//  BidRequest.swift
//  Bidon
//
//  Created by Stas Kochkin on 30.05.2023.
//

import Foundation


struct BidRequest: Request {
    var route: Route
    var method: HTTPTask.HTTPMethod = .post
    var headers: [HTTPTask.HTTPHeader: String] = .default()
    var timeout: TimeInterval = 10
    var body: RequestBody?
   
    struct RequestBody: Encodable, Tokenized {
        struct ImpModel: Encodable {
            var id: String = UUID().uuidString
            var bidfloor: Price
            var auctionId: String
            var auctionConfigurationId: Int
            var roundId: String
            var orientation: InterfaceOrientation = .current
            var banner: AdViewAucionContextModel?
            var interstitial: InterstitialAuctionContextModel?
            var rewarded: RewardedAuctionContextModel?
            var demands: BidonBiddingExtrasModel
        }
        
        var device: DeviceModel?
        var session: SessionModel?
        var app: AppModel?
        var user: UserModel?
        var regs: RegulationsModel?
        var ext: String?
        var test: Bool
        var token: String?
        var segmentId: String?
        var adapters: AdaptersInfo
        var imp: ImpModel
    }
    
    struct ResponseBody: Decodable, Tokenized {
        struct BidModel: Decodable {
            enum CodingKeys: String, CodingKey {
                case id
                case impressionId = "impid"
                case winNoticeUrl = "nurl"
                case billingNoticeUrl = "burl"
                case lossNoticeUrl = "lurl"
                case price
                case demandId
                case payload
            }
            
            var id: String
            var impressionId: String
            var winNoticeUrl: String?
            var billingNoticeUrl: String?
            var lossNoticeUrl: String?
            var price: Price
            var demandId: String
            var payload: String
        }
        
        var token: String?
        var segmentId: String?
        var bid: BidModel
    }
    
    init<T: BidRequestBuilder>(_ build: (T) -> ()) {
        let builder = T()
        build(builder)
        
        self.route = .complex(.adType(builder.adType), .bid)
        
        self.body = RequestBody(
            device: builder.device,
            session: builder.session,
            app: builder.app,
            user: builder.user,
            regs: builder.regulations,
            ext: builder.encodedExt,
            test: builder.testMode,
            adapters: builder.adapters,
            imp: builder.imp
        )
    }
}

