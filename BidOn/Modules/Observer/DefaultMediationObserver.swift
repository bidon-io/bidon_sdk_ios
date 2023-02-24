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
    var eCPM: Price = .unknown
    var isRoundWinner: Bool = false
    var bidRequestTimestamp: TimeInterval? = Date.timestamp(.wall, units: .milliseconds)
    var bidResponeTimestamp: TimeInterval?
    var fillRequestTimestamp: TimeInterval?
    var fillResponseTimestamp: TimeInterval?
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
                winnerECPM: winner?.eCPM,
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
    
    @Atomic
    private(set) var firedLineItems: [LineItem] = []
    
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
            lineItem.map { self.firedLineItems.append($0) }
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
                observation.eCPM = bid.ad.eCPM
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
                condition: { $0.adId != ad.id && $0.status.isUnknown }
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


private extension DefaultDemandReport {
    init(_ observation: DemandObservation) {
        self.networkId = observation.networkId
        self.adUnitId = observation.adUnitId
        self.eCPM = observation.eCPM
        self.status = observation.status
        self.bidStartTimestamp = observation.bidRequestTimestamp?.uint
        self.bidFinishTimestamp = observation.bidResponeTimestamp?.uint
        self.fillStartTimestamp = observation.fillRequestTimestamp?.uint
        self.fillFinishTimestamp = observation.fillResponseTimestamp?.uint
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
