//
//  MockBetStorage.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Combine
@testable import BigBet

class MockBetStorage: BetStorageProtocol {
    var betsSubject = PassthroughSubject<[Bet], Never>()
    var betUpdateSubject = PassthroughSubject<Bet, Never>()
    private var bets: [Bet] = []

    func getAllBets() -> [Bet] {
        return bets
    }

    func addBet(_ bet: Bet) {
        bets.append(bet)
        betsSubject.send(bets)
    }

    func removeBetForEvent(id: String) {
        bets.removeAll { $0.event.id == id }
        betsSubject.send(bets)
    }

    func getBetForEvent(id: String) -> Bet? {
        return bets.first { $0.event.id == id }
    }
}
