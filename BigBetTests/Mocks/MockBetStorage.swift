//
//  MockBetStorage.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import RxSwift
import RxRelay
@testable import BigBet

class MockBetStorage: BetStorageProtocol {
    var betsSubject = PublishRelay<[Bet]>()
    var betUpdateSubject = PublishRelay<Bet>()
    private var bets: [Bet] = []

    func getAllBets() -> [Bet] {
        return bets
    }

    func addBet(_ bet: Bet) {
        bets.append(bet)
        betsSubject.accept(bets)
    }

    func removeBetForEvent(id: String) {
        bets.removeAll { $0.event.id == id }
        betsSubject.accept(bets)
    }

    func getBetForEvent(id: String) -> Bet? {
        return bets.first { $0.event.id == id }
    }
}
