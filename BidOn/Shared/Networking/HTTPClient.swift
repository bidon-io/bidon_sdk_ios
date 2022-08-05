//
//  HTTPClient.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation



struct HTTPClient {
    enum Route: String {
        case config = "config"
        case auction = "auction"
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum HTTPError: Error {
        case unsupportedURL
        case invalidResponse
        case rateLimitted(retryAfterSeconds: TimeInterval)
        case encoding(Error)
        case decoding(Error)
        case networking(Error)
    }
    
    enum HTTPHeader: String {
        case contentType = "Content-Type"
        case accept = "Accept"
        case sdkVersion = "X-BidOn-Version"
        case retryAfter = "Retry-After"
    }
    
    func request<RequestData: Encodable, ResponseData: Decodable> (
        _ baseURL: String,
        _ route: Route,
        _ method: HTTPMethod = .post,
        _ body: RequestData,
        _ timeout: TimeInterval = 10,
        _ headers: [HTTPHeader: String] = [
            .contentType : "application/json",
            .accept: "application/json",
            .sdkVersion: BidOnSdk.sdkVersion
        ],
        success: ((ResponseData?) -> ())?,
        failure: ((HTTPError) -> ())?
    ) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let url = URL(string: baseURL)?.appendingPathComponent(route.rawValue) else {
            failure?(.unsupportedURL)
            return
        }
        
        let session = URLSession.shared
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeout
        )
        
        headers.forEach { header, value in
            request.addValue(value, forHTTPHeaderField: header.rawValue)
        }
        
        request.httpMethod = method.rawValue
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            failure?(.encoding(error))
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                failure?(.networking(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                failure?(.invalidResponse)
                return
            }
            
            switch response.statusCode {
            case 200..<300:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let data = try data.map { try decoder.decode(ResponseData.self, from: $0) }
                    success?(data)
                } catch {
                    failure?(.decoding(error))
                }
            default:
                failure?(.invalidResponse)
            }
        }
        .resume()
    }
}
