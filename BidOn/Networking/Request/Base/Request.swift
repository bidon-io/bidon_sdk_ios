//
//  Request.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


indirect enum Route {
    case config
    case auction
    case stats
    case show
    case adType(AdType)
    case complex(Route, Route)
}


extension HTTPClient.HTTPHeaders {
    static func `default`() -> HTTPClient.HTTPHeaders {
        return [
            .contentType : "application/json",
            .accept: "application/json",
            .sdkVersion: BidOnSdk.sdkVersion
        ]
    }
}


protocol Tokenized {
    var token: String? { get set }
}


protocol Request {
    associatedtype RequestBody: Encodable & Tokenized
    associatedtype ResponseBody: Decodable & Tokenized
    
    var route: Route { get }
    var method: HTTPClient.HTTPMethod { get }
    var headers: [HTTPClient.HTTPHeader: String] { get }
    var timeout: TimeInterval { get }
    var body: RequestBody? { get }
}


extension Route {
    func url(_ base: URL) -> URL {
        switch self {
        case .auction: return base.appendingPathComponent("auction")
        case .config: return base.appendingPathComponent("config")
        case .stats: return base.appendingPathComponent("stats")
        case .show: return base.appendingPathComponent("show")
        case .adType(let adType): return base.appendingPathComponent(adType.rawValue)
        case .complex(let left, let right): return right.url(left.url(base))
        }
    }
}
