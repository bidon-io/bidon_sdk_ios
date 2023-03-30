//
//  StatisticRequest.swift
//  Bidon
//
//  Created by Bidon Team on 31.08.2022.
//

import Foundation


struct StatisticRequest: Request {
    var route: Route
    var method: HTTPTask.HTTPMethod = .post
    var headers: [HTTPTask.HTTPHeader: String] = .default()
    var timeout: TimeInterval = 10
    var body: RequestBody?
    
    struct RequestBody: Encodable, Tokenized {
        var device: DeviceModel?
        var session: SessionModel?
        var app: AppModel?
        var user: UserModel?
        var geo: GeoModel?
        var ext: String?
        var test: Bool
        var token: String?
        var segmentId: String?
        var stats: MediationAttemptReportCodableModel
    }
    
    struct ResponseBody: Decodable, Tokenized {
        var token: String?
        var segmentId: String?
        var success: Bool
    }
    
    init(_ build: (StatisticRequestBuilder) -> ()) {
        let builder = StatisticRequestBuilder()
        build(builder)
        
        self.route = .complex(.adType(builder.adType), .stats)
        self.body = RequestBody(
            device: builder.device,
            session: builder.session,
            app: builder.app,
            user: builder.user,
            geo: builder.geo,
            ext: builder.encodedExt,
            test: builder.testMode,
            stats: builder.stats
        )
    }
}
