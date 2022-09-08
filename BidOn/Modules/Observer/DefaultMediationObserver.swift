//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation


fileprivate struct DemandObservation {
    var networkId: String
    var roundId: String
    var adUnitId: String?
    var adId: String? = nil
    var status: DemandResult = .unknown
    var price: Price = .unknown
    var isRoundWinner: Bool = false
    var bidRequestTimestamp: TimeInterval = Date.timestamp(.wall, units: .milliseconds)
    var bidResponeTimestamp: TimeInterval = .zero
    var fillRequestTimestamp: TimeInterval = .zero
    var fillResponseTimestamp: TimeInterval = .zero
}


fileprivate struct RoundObservation {
    var roundId: String
    var pricefloor: Price
}


final class DefaultMediationObserver<T: DemandProvider>: MediationObserver {
    let auctionId: String
    let auctionConfigurationId: Int
    let adType: AdType
    
    weak var delegate: MediationObserverDelegate?
    
    var report: DefaultMediationAttemptReport {
        let rounds: [DefaultRoundReport] = roundObservations.map { round in
            let demands = demandObservations
                .filter { $0.roundId == round.roundId }
            
            let winner = demands.first { $0.isRoundWinner }
            
            return DefaultRoundReport(
                roundId: round.roundId,
                pricefloor: round.pricefloor,
                winnerPrice: winner?.price,
                winnerNetworkId: winner?.networkId,
                demands: demands.map { DefaultDemandReport($0) }
            )
        }
        
        return DefaultMediationAttemptReport(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            rounds: rounds
        )
    }
    
    @Atomic
    private var demandObservations: [DemandObservation] = []
    
    @Atomic
    private var roundObservations: [RoundObservation] = []
    
    init(
        auctionId id: String,
        auctionConfigurationId configurationId: Int,
        adType: AdType
    ) {
        self.adType = adType
        self.auctionId = id
        self.auctionConfigurationId = configurationId
    }
    
    func log(_ event: MediationEvent<T>) {
        Logger.debug("[\(adType)] [Auction: \(auctionId)] " + event.description)
        
        switch event {
        case .auctionStart:
            delegate?.didStartAuction(auctionId)
        case .roundStart(let round, let pricefloor):
            roundObservations.append(
                RoundObservation(
                    roundId: round.id,
                    pricefloor: pricefloor
                )
            )
            delegate?.didStartAuctionRound(round, pricefloor: pricefloor)
        case .bidRequest(let round, let adapter, let lineItem):
            demandObservations.append(
                DemandObservation(
                    networkId: adapter.identifier,
                    roundId: round.id,
                    adUnitId: lineItem?.adUnitId
                )
            )
        case .bidResponse(let round, let adapter, let bid):
            demandObservations.update(
                condition: { $0.roundId == round.id && $0.networkId == adapter.identifier }
            ) { observation in
                observation.adId = bid.ad.id
                observation.price = bid.ad.price
                observation.bidResponeTimestamp = Date.timestamp(.wall, units: .milliseconds)
            }
            delegate?.didReceiveBid(bid.ad, provider: bid.provider)
        case .bidError(let round, let adapter, let error):
            demandObservations.update(
                condition: { $0.roundId == round.id && $0.networkId == adapter.identifier }
            ) { observation in
                observation.status = DemandResult(error)
                observation.bidResponeTimestamp = Date.timestamp(.wall, units: .milliseconds)
            }
        case .roundFinish(let round, let winner):
            if let winner = winner {
                demandObservations.update(
                    condition: { $0.adId == winner.id }
                ) { observation in
                    observation.isRoundWinner = true
                }
            }
            delegate?.didFinishAuctionRound(round)
        case .auctionFinish(let winner):
            delegate?.didFinishAuction(auctionId, winner: winner)
        case .fillRequest(let ad):
            demandObservations.update(
                condition: { $0.adId == ad.id }
            ) { observation in
                observation.fillRequestTimestamp = Date.timestamp(.wall, units: .milliseconds)
            }
        case .fillResponse(let ad):
            demandObservations.update(
                condition: { $0.adId == ad.id }
            ) { observation in
                observation.fillResponseTimestamp = Date.timestamp(.wall, units: .milliseconds)
                observation.status = .win
            }
            demandObservations.update(
                condition: { $0.adId != ad.id && $0.status == .unknown }
            ) { observation in
                observation.status = .lose
            }
        case .fillError(let ad, let error):
            demandObservations.update(
                condition: { $0.adId == ad.id }
            ) { observation in
                observation.fillResponseTimestamp = Date.timestamp(.wall, units: .milliseconds)
                observation.status = DemandResult(error)
            }
        case .fillStart, .fillFinish:
            break
        }
    }
}


private extension DemandResult {
    init(_ error: MediationError) {
        switch error {
        case .noBid: self = .noBid
        case .noFill: self = .noFill
        case .unknownAdapter: self = .unknown
        case .adapterNotInitialized: self = .adapterNotInitialized
        case .bidTimeoutReached: self = .bidTimeoutReached
        case .fillTiemoutReached: self = .fillTiemoutReached
        case .networkError: self = .networkError
        case .incorrectAdUnitId: self = .incorrectAdUnitId
        case .noApproperiateAdUnitId: self = .noApproperiateAdUnitId
        case .auctionCancelled: self = .auctionCancelled
        case .adFormatNotSupported: self = .adFormatNotSupported
        case .unscpecifiedException: self = .unscpecifiedException
        case .belowPricefloor: self = .belowPricefloor
        }
    }
}


private extension DefaultDemandReport {
    init(_ observation: DemandObservation) {
        self.networkId = observation.networkId
        self.adUnitId = observation.adUnitId
        self.price = observation.price
        self.status = observation.status
        self.bidStartTimestamp = observation.bidRequestTimestamp
        self.bidFinishTimestamp = observation.bidResponeTimestamp
        self.fillStartTimestamp = observation.fillRequestTimestamp
        self.fillFinishTimestamp = observation.fillResponseTimestamp
    }
}


private extension Array where Element == DemandObservation {
    mutating func update(
        condition: (Element) -> Bool,
        mutation: (inout Element) -> ()
    ) {
        self = map { element in
            guard condition(element) else { return element }
            var element = element
            mutation(&element)
            return element
        }
    }
}
