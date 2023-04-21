//
//  MediationObserver.swift
//  Bidon
//
//  Created by Bidon Team on 31.08.2022.
//

import Foundation


fileprivate struct DemandObservation {
    var networkId: String
    var roundId: String
    var adUnitId: String?
    var adId: String? = nil
    var status: DemandReportStatus = .unknown
    var eCPM: Price = .unknown
    var isRoundWinner: Bool = false
    var isAuctionWinner: Bool = false
    var bidRequestTimestamp: TimeInterval? = Date.timestamp(.wall, units: .milliseconds)
    var bidResponeTimestamp: TimeInterval?
    var fillRequestTimestamp: TimeInterval?
    var fillResponseTimestamp: TimeInterval?
}


fileprivate struct RoundObservation {
    var roundId: String
    var pricefloor: Price
}


final class BaseMediationObserver: MediationObserver {
    let auctionId: String
    let auctionConfigurationId: Int
    let adType: AdType
    
    var report: MediationAttemptReportModel {
        let rounds: [RoundReportModel] = roundObservations.map { round in
            let demands = demandObservations
                .filter { $0.roundId == round.roundId }
            
            let winner = demands.first { $0.isRoundWinner }
            
            return RoundReportModel(
                roundId: round.roundId,
                pricefloor: round.pricefloor,
                winnerECPM: winner?.eCPM,
                winnerNetworkId: winner?.networkId,
                demands: demands.map { DemandReportModel($0) }
            )
        }
        
        let winner = demandObservations.first { $0.isAuctionWinner }
        let result = AuctionResultReportModel(
            status: winner != nil ? .success : .fail,
            winnerNetworkId: winner?.networkId,
            winnerECPM: winner?.eCPM,
            winnerAdUnitId: winner?.adUnitId
        )
        
        return MediationAttemptReportModel(
            auctionId: auctionId,
            auctionConfigurationId: auctionConfigurationId,
            rounds: rounds,
            result: result
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
    
    func log(_ event: MediationEvent) {
        Logger.debug("[\(adType)] [Auction: \(auctionId)] " + event.description)
        
        #warning("Mediation Event handling")
        switch event {
//        case .roundStart(let round, let pricefloor):
//            proceedRoundStart(
//                round,
//                pricefloor: pricefloor
//            )
//        case .bidRequest(let round, let adapter, let lineItem):
//            proceedBidRequest(
//                round: round,
//                adapter: adapter,
//                lineItem: lineItem
//            )
//        case .bidResponse(let round, let adapter, let bid):
//            proceedBidResponse(
//                round: round,
//                adapter: adapter,
//                bid: bid
//            )
//        case .bidError(let round, let adapter, let error):
//            proceedBidError(
//                round: round,
//                adapter: adapter,
//                error: error
//            )
//        case .roundFinish(_, let winner):
//            proceedRoundFinish(winner: winner)
//        case .fillRequest(let bid):
//            proceedFillRequest(bid: bid)
//        case .fillResponse(let bid):
//            proceedFillResponse(bid: bid)
//        case .fillError(let bid, let error):
//            proceedFillError(
//                bid: bid,
//                error: error
//            )
        default:
            break
        }
    }
    
    private func proceedRoundStart(
        _ round: AuctionRound,
        pricefloor: Price
    ) {
        $roundObservations.mutate {
            $0.append(
                RoundObservation(
                    roundId: round.id,
                    pricefloor: pricefloor
                )
            )
        }
    }
    
    private func proceedBidRequest(
        round: AuctionRound,
        adapter: Adapter,
        lineItem: LineItem?
    ) {        
        $demandObservations.appendIfNeeded(
            DemandObservation(
                networkId: adapter.identifier,
                roundId: round.id,
                adUnitId: lineItem?.adUnitId
            )
        )
    }
    
    private func proceedBidResponse(
        round: AuctionRound,
        adapter: Adapter,
        bid: some Bid
    ) {
        $demandObservations.update(condition: {
            $0.roundId == round.id && $0.networkId == adapter.identifier }
        ) { observation in
            observation.adId = bid.ad.id
            observation.eCPM = bid.eCPM
            observation.bidResponeTimestamp = Date.timestamp(.wall, units: .milliseconds)
        }
    }
    
    private func proceedBidError(
        round: AuctionRound,
        adapter: Adapter,
        error: MediationError
    ) {
        $demandObservations.update(condition: {
            $0.roundId == round.id && $0.networkId == adapter.identifier
        }) { observation in
            observation.status = DemandReportStatus(error)
            observation.bidResponeTimestamp = Date.timestamp(.wall, units: .milliseconds)
        }
    }
    
    private func proceedRoundFinish(winner: (any Bid)?) {
        guard let winner = winner else { return }
        $demandObservations.update(condition: {
            $0.adId == winner.ad.id
        }) { observation in
            observation.isRoundWinner = true
        }
    }
    
    private func proceedFillRequest(bid: some Bid) {
        $demandObservations.update(condition: {
            $0.adId == bid.ad.id
        }) { observation in
            observation.fillRequestTimestamp = Date.timestamp(.wall, units: .milliseconds)
        }
    }
    
    private func proceedFillResponse(bid: some Bid) {
        $demandObservations.update(
            condition: { $0.adId == bid.ad.id }
        ) { observation in
            observation.fillResponseTimestamp = Date.timestamp(.wall, units: .milliseconds)
            observation.status = .win
            observation.isAuctionWinner = true
        }
        
        $demandObservations.update(
            condition: { $0.adId != bid.ad.id && $0.status.isUnknown }
        ) { observation in
            observation.status = .lose
        }
    }
    
    private func proceedFillError(
        bid: some Bid,
        error: MediationError
    ) {
        $demandObservations.update(condition: {
            $0.adId == bid.ad.id
        }) { observation in
            observation.fillResponseTimestamp = Date.timestamp(.wall, units: .milliseconds)
            observation.status = DemandReportStatus(error)
        }
    }
}


private extension DemandReportModel {
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


private extension Atomic where Value: RangeReplaceableCollection {
    func appendIfNeeded(_ element: Value.Element?) {
        guard let element = element else { return }
        mutate { $0.append(element) }
    }
}


private extension Atomic where Value == [DemandObservation] {
    func update(
        condition: (DemandObservation) -> Bool,
        mutation: (inout DemandObservation) -> ()
    ) {
        mutate { value in
            value = value.map { element in
                guard condition(element) else { return element }
                var element = element
                mutation(&element)
                return element
            }
        }
    }
}
