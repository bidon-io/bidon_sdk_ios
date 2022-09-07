//
//  MediationObserver.swift
//  BidOn
//
//  Created by Stas Kochkin on 31.08.2022.
//

import Foundation



struct ObservationData: MediationAttemptReport {
    typealias RoundLogType = RoundObservationData
    
    var auctionId: String
    var auctionConfigurationId: Int
    var rounds: [RoundObservationData]
}


struct RoundObservationData: RoundReport {
    typealias DemandLogType = DemandObservationData
    
    var id: String
    var pricefloor: Price
    var winnerPrice: Price?
    var winnerId: String?
    var demands: [DemandObservationData]
}


struct DemandObservationData: DemandReport {
    var id: String
    var adUnitId: String?
    var format: String
    var status: DemandResult
    var startTimestamp: TimeInterval
    var finishTimestamp: TimeInterval
}


final class DefaultMediationObserver<T: DemandProvider>: MediationObserver {
    let auctionId: String
    let auctionConfigurationId: Int
    let adType: AdType
    
    weak var delegate: MediationObserverDelegate?
    
    var report: ObservationData {
        ObservationData(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            rounds: rounds
        )
    }
    
    @Atomic
    private var rounds: [RoundObservationData] = []
    
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
            startObservingRound(round, pricefloor: pricefloor)
            delegate?.didStartAuctionRound(round, pricefloor: pricefloor)
            break
        case .bidRequest(let round, let adapter, let lineItem):
            startObservingDemand(adapter, auctionRound: round, lineItem: lineItem)
        case .bidResponse(let round, let adapter, let bid):
            updateDemand(auctionRound: round, demand: adapter.identifier) { data in
                data.finishTimestamp = Date.timestamp(.wall, units: .milliseconds)
                data.status = .win
            }
            delegate?.didReceiveBid(bid.ad, provider: bid.provider)
        case .bidError(let round, let adapter, let error):
            break
        case .roundFinish(let round, let winner):
            finishObservingRound(round, winner: winner)
            delegate?.didFinishAuctionRound(round)
        case .auctionFinish(let winner):
            delegate?.didFinishAuction(auctionId, winner: winner)
        case .fillStart:
            break
        case .fillRequest(let ad):
            break
        case .fillResponse(let ad):
            break
        case .fillError(let ad, let error):
            break
        case .fillFinish(let winner):
            break
        }
    }
    
    private func startObservingRound(
        _ aucitonRound: AuctionRound,
        pricefloor: Price
    ) {
        let observation = RoundObservationData(
            id: aucitonRound.id,
            pricefloor: pricefloor,
            demands: []
        )
        
        rounds.append(observation)
    }
    
    private func startObservingDemand(
        _ adapter: Adapter,
        auctionRound: AuctionRound,
        lineItem: LineItem?
    ) {
        rounds.update(auctionRound) { roundObservation in
            let demandObservation = DemandObservationData(
                id: adapter.identifier,
                adUnitId: lineItem?.adUnitId,
                format: "",
                status: .unscpecifiedException,
                startTimestamp: Date.timestamp(.wall, units: .milliseconds),
                finishTimestamp: .zero
            )
            
            roundObservation.demands.append(demandObservation)
        }
    }
    
    private func updateDemand(
        auctionRound: AuctionRound,
        demand: String,
        mutation: (inout DemandObservationData) -> ()
    ) {
        rounds.update(auctionRound) { roundObservation in
            roundObservation.demands.update(demand, mutation: mutation)
        }
    }
    
    private func finishObservingRound(
        _ aucitonRound: AuctionRound,
        winner: Ad?
    ) {
        rounds.update(aucitonRound) { round in
            round.winnerId = winner?.networkName
            round.winnerPrice = winner?.price
        }
    }
    //    func startBid(
    //        demand: String,
    //        round: AuctionRound,
    //        pricefloor: Price
    //    ) {
    //        let observation = Observation(
    //            round: round.id,
    //            pricefloor: pricefloor,
    //            demand: demand
    //        )
    //
    //        observations.insert(observation)
    //    }
    //
    //    func captureBid(
    //        ad: Ad,
    //        round: AuctionRound
    //    ) {
    //        observations = observations.replace(
    //            where: { $0.demand == ad.networkName && $0.round == round.id },
    //            transformation: { observation in
    //                observation.adId = ad.id
    //                observation.price = ad.price
    //                observation.bidResponseTimestamp = Date.timestamp(.wall, units: .milliseconds)
    //            }
    //        )
    //    }
    //
    //    func failure(
    //        ad: Ad,
    //        error: SdkError
    //    ) {
    //
    //    }
    //
    //    func failure(
    //        demand: String,
    //        round: AuctionRound,
    //        error: SdkError
    //    ) {
    //
    //    }
    //
    //    func roundWin(ad: Ad) {
    //
    //    }
}


private extension Array where Element == RoundObservationData {
    mutating func update(_ round: AuctionRound, mutation: (inout Element) -> ()) {
        self = map { observation in
            guard observation.id == round.id else { return observation }
            var observation = observation
            mutation(&observation)
            return observation
        }
    }
}


private extension Array where Element == DemandObservationData {
    mutating func update(_ demandId: String, mutation: (inout Element) -> ()) {
        self = map { observation in
            guard observation.id == demandId else { return observation }
            var observation = observation
            mutation(&observation)
            return observation
        }
    }
}


//private extension Observations {
//    func replace(
//        where condition: @escaping (Element) -> Bool,
//        transformation: @escaping (inout Element) -> Void
//    ) -> Observations {
//        return Observations(
//            self.lazy.map { element in
//                guard condition(element) else { return element }
//                var _element = element
//                transformation(&_element)
//                return _element
//            }
//        )
//    }
//}
//
//
//extension DefaultMediationObserver.Observation: Equatable, Hashable {
//    static func == (lhs: DefaultMediationObserver.Observation, rhs: DefaultMediationObserver.Observation) -> Bool {
//        return lhs.round == rhs.round && lhs.demand == rhs.demand
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(round)
//        hasher.combine(demand)
//    }
//}
