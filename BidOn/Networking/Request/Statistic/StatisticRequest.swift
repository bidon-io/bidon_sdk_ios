//
//  StatisticRequest.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct StatisticRequest: Request {
    var route: Route
    var method: HTTPClient.HTTPMethod = .post
    var headers: [HTTPClient.HTTPHeader: String] = .default()
    var timeout: TimeInterval = 10
    var body: RequestBody?
    
    struct RequestBody: Encodable, Tokenized {
        var device: DeviceModel?
        var session: SessionModel?
        var app: AppModel?
        var user: UserModel?
        var geo: GeoModel?
        var ext: String?
        var token: String?
        var stats: MediationAttemptReportModel
    }
    
    struct ResponseBody: Decodable, Tokenized {
        var token: String?
        var success: Bool
    }
    
    init(_ build: (StatisticRequestBuilder) -> ()) {
        let builder = StatisticRequestBuilder()
        build(builder)
        
        self.route = .complex(.stats, .adType(builder.adType))
        self.body = RequestBody(
            device: builder.device,
            session: builder.session,
            app: builder.app,
            user: builder.user,
            geo: builder.geo,
            ext: builder.encodedExt,
            stats: builder.stats
        )
    }
}
