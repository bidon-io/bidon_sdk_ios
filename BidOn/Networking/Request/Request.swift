//
//  Request.swift
//  BidOn
//
//  Created by Stas Kochkin on 09.08.2022.
//

import Foundation


enum Route: String {
    case config = "config"
    case auction = "auction"
    case stats = "stats"
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
