//
//  HTTPClient.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation



struct HTTPClient {
    var baseURL: String
    
    typealias HTTPHeaders = [HTTPHeader: String]
    
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
    
    func request(
        _ route: Route,
        _ body: Data?,
        _ method: HTTPMethod,
        _ timeout: TimeInterval,
        _ headers: [HTTPHeader: String],
        completion: @escaping (Result<Data, HTTPError>) -> ()
    ) {
        guard let url = URL(string: baseURL).map({ route.url($0) }) else {
            completion(.failure(.unsupportedURL))
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
        request.httpBody = body
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networking(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if response.statusCode >= 200, response.statusCode < 300, let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.invalidResponse))
            }
        }
        .resume()
    }
}
