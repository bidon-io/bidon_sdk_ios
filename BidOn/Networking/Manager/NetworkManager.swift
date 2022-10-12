//
//  NetworkManager.swift
//  BidOn
//
//  Created by Stas Kochkin on 08.08.2022.
//

import Foundation


protocol NetworkManager {
    typealias Completion<W: Request> = (Result<W.ResponseBody, HTTPTask.HTTPError>) -> ()
    
    var baseURL: String { get set }
    
    func perform<T: Request>(
        request: T,
        completion: @escaping Completion<T>
    )
}


fileprivate struct NetworkManagerInjectionKey: InjectionKey {
    static var currentValue: NetworkManager = PersistentNetworkManager.shared
}


extension InjectedValues {
    var networkManager: NetworkManager {
        get { Self[NetworkManagerInjectionKey.self] }
        set { Self[NetworkManagerInjectionKey.self] = newValue }
    }
}


fileprivate final class PersistentNetworkManager: NetworkManager {
    static let shared = PersistentNetworkManager()
    
    @UserDefaultOptional(Constants.UserDefaultsKey.token)
    private var token: String?
    
    var baseURL: String = Constants.API.baseURL
    
    func perform<T: Request>(
        request: T,
        completion: @escaping (Result<T.ResponseBody, HTTPTask.HTTPError>) -> ()
    ) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        var body = request.body
        body?.token = token
        
        var data: Data?
        
        do {
            data = try encoder.encode(body)
        } catch {
            completion(.failure(.encoding(error)))
        }
        
        guard let data = data else { return }
        
        HTTPTask(
            baseURL: baseURL,
            route: request.route,
            body: data,
            method: request.method,
            timeout: request.timeout,
            headers: request.headers
        ) { result in
            // TODO: Cache logic
            DispatchQueue.main.async { [unowned self] in
                switch result {
                case .success(let raw):
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let response = try decoder.decode(T.ResponseBody.self, from: raw)
                        self.token = response.token
                        
                        completion(.success(response))
                    } catch {
                        completion(.failure(.decoding(error)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        .resume()
    }
}
