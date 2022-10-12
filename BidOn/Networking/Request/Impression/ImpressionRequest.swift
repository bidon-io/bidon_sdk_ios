//
//  ActionRequest.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


struct ImpressionRequest: Request {
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
        var token: String?
        var show: ImpressionModel
    }
    
    struct ResponseBody: Decodable, Tokenized {
        var token: String?
        var success: Bool
    }
    
    init<T: ImpressionRequestBuilder>(_ build: (T) -> ()) {
        let builder = T()
        build(builder)
    
        self.route = builder.route
        
        self.body = RequestBody(
            device: builder.device,
            session: builder.session,
            app: builder.app,
            user: builder.user,
            geo: builder.geo,
            ext: builder.encodedExt,
            show: builder.imp
        )
    }
}
