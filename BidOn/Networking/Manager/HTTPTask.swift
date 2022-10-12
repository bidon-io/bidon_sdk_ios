//
//  HTTPClient.swift
//  BidOn
//
//  Created by Stas Kochkin on 04.08.2022.
//

import Foundation


struct HTTPTask {
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
    
    var baseURL: String
    var route: Route
    var body: Data?
    var method: HTTPMethod
    var timeout: TimeInterval
    var headers: HTTPHeaders
    var completion: (Result<Data, HTTPError>) -> ()
    
    func resume() {
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
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if response.statusCode >= 200, response.statusCode < 300, let data = data {
                completion(.success(data))
            } else if let retryAfter = response.retryAfterSeconds, retryAfter > 0 {
                completion(.failure(.rateLimitted(retryAfterSeconds: retryAfter)))
            } else if let error = error {
                completion(.failure(.networking(error)))
            } else {
                completion(.failure(.invalidResponse))
            }
        }
    
        task.resume()
    }
}


private extension HTTPURLResponse {
    var retryAfterSeconds: TimeInterval? {
        return allHeaderFields[HTTPTask.HTTPHeader.retryAfter.rawValue]
            .flatMap { $0 as? String }
            .flatMap { Double($0) }
            .map { Date.MeasurementUnits.milliseconds.convert($0, to: .seconds) }
    }
}
