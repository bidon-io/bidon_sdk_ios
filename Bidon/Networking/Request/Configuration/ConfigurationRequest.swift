//
//  File.swift
//  Bidon
//
//  Created by Bidon Team on 09.08.2022.
//

import Foundation


struct ConfigurationRequest: Request {
    var id: String = UUID().uuidString
    var route: Route = .config
    var method: HTTPTask.HTTPMethod = .post
    var headers: [HTTPTask.HTTPHeader: String] = .default()
    var timeout: TimeInterval = 10
    var body: RequestBody?
    
    struct RequestBody: Encodable, Tokenized {
        var test: Bool
        var token: String?
        var ext: String?
        var adapters: AdaptersInfo
        var app: AppModel
        var regs: RegulationsModel
        var session: SessionModel
        var user: UserModel
        var device: DeviceModel
        var segment: SegmentModel
    }
    
    struct ResponseBody: Decodable, Tokenized {
        var adaptersInitializationParameters: AdaptersInitialisationParameters
        var token: String?
        var segment: SegmentResponseModel?
        
        enum CodingKeys: String, CodingKey {
            case adaptersInitializationParameters = "init"
            case token = "token"
            case segment
        }
    }
}


extension ConfigurationRequest {
    init(_ build: (ConfigurationRequestBuilder) -> ()) {
        let builder = ConfigurationRequestBuilder()
        build(builder)
        
        self.body = RequestBody(
            test: builder.testMode,
            ext: builder.encodedExt,
            adapters: builder.adapters,
            app: builder.app,
            regs: builder.regulations,
            session: builder.session,
            user: builder.user,
            device: builder.device,
            segment: builder.segment
        )
    }
}


extension ConfigurationRequest: Equatable {
    static func == (lhs: ConfigurationRequest, rhs: ConfigurationRequest) -> Bool {
        return lhs.id == rhs.id
    }
}
