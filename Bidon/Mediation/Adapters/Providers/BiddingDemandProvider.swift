//
//  BiddingDemandProvider.swift
//  Bidon
//
//  Created by Bidon Team on 31.05.2023.
//

import Foundation


public typealias BiddingContextEncoderResponse = (Result<Encodable, MediationError>) -> ()


public protocol GenericBiddingDemandProvider: DemandProvider {
    func collectBiddingTokenEncoder(
        adUnitExtrasDecoder: Decoder,
        response: @escaping BiddingContextEncoderResponse
    )
    
    func load(
        payloadDecoder: Decoder,
        adUnitExtrasDecoder: Decoder,
        response: @escaping DemandProviderResponse
    )
}


public protocol BiddingDemandProvider: GenericBiddingDemandProvider {
    associatedtype BiddingToken: Encodable
    associatedtype BiddingPayload: Decodable
    associatedtype AdUnitExtras: Decodable
    
    func collectBiddingToken(
        adUnitExtras: AdUnitExtras,
        response: @escaping (Result<BiddingToken, MediationError>) -> ()
    )
    
    func load(
        payload: BiddingPayload,
        adUnitExtras: AdUnitExtras?,
        response: @escaping DemandProviderResponse
    )
}


extension BiddingDemandProvider {
    public func collectBiddingTokenEncoder(
        adUnitExtrasDecoder: Decoder,
        response: @escaping BiddingContextEncoderResponse
    ) {
        do {
            let adUnitExtas = try AdUnitExtras(from: adUnitExtrasDecoder)
            collectBiddingToken(adUnitExtras: adUnitExtas) { result in
                switch result {
                case .failure(let error):
                    response(.failure(error))
                case .success(let context):
                    response(.success(context))
                }
            }
        } catch {
            response(.failure(.incorrectAdUnitId))
        }
    }
    
    public func load(
        payloadDecoder: Decoder,
        adUnitExtrasDecoder: Decoder,
        response: @escaping DemandProviderResponse
    ) {
        do {
            let payload = try BiddingPayload(from: payloadDecoder)
            let adUnitExtas = try AdUnitExtras(from: adUnitExtrasDecoder)
            
            load(
                payload: payload,
                adUnitExtras: adUnitExtas,
                response: response
            )
        } catch {
            response(.failure(.incorrectAdUnitId))
        }
    }
}


final class BiddingDemandProviderWrapper<W>: DemandProviderWrapper<W>, GenericBiddingDemandProvider {
    private let _collectBiddingTokenEncoder: (Decoder, @escaping BiddingContextEncoderResponse) -> ()
    private let _load: (Decoder, Decoder, @escaping DemandProviderResponse) -> ()
    
    override init(_ wrapped: W) throws {
        guard let _wrapped = wrapped as? (any GenericBiddingDemandProvider)
        else { throw SdkError.internalInconsistency }
        
        _collectBiddingTokenEncoder = { _wrapped.collectBiddingTokenEncoder(adUnitExtrasDecoder: $0, response: $1) }
        _load = { _wrapped.load(payloadDecoder: $0, adUnitExtrasDecoder: $1, response: $2) }
        
        try super.init(wrapped)
    }
    
    func collectBiddingTokenEncoder(
        adUnitExtrasDecoder: Decoder,
        response: @escaping BiddingContextEncoderResponse
    ) {
        _collectBiddingTokenEncoder(adUnitExtrasDecoder, response)
    }
    
    func load(
        payloadDecoder: Decoder,
        adUnitExtrasDecoder: Decoder,
        response: @escaping DemandProviderResponse
    ) {
       _load(payloadDecoder, adUnitExtrasDecoder, response)
    }
}