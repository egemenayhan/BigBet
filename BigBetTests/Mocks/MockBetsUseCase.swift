//
//  MockBetsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Combine
@testable import BigBet

class MockBetsUseCase: BetsUseCaseProtocol {
    private var storage: MockBetStorage
    private var analyticsUseCase: MockAnalyticsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    var totalBetPrice = CurrentValueSubject<Double, Never>(0)
    var betsSubject: PassthroughSubject<[Bet], Never> {
        return storage.betsSubject
    }
    var betUpdateSubject: PassthroughSubject<Bet, Never> {
        return storage.betUpdateSubject
    }

    init(storage: MockBetStorage, analyticsUseCase: MockAnalyticsUseCase) {
        self.storage = storage
        self.analyticsUseCase = analyticsUseCase

        storage.betsSubject
            .sink { [weak self] bets in
                self?.calculateTotalBetPrice(bets: bets)
            }
            .store(in: &cancellables)
    }

    private func calculateTotalBetPrice(bets: [Bet]) {
        totalBetPrice.value = bets.reduce(1) { $0 * $1.odd.price }
        totalBetPrice.send(totalBetPrice.value)
    }

    func getAllBets() -> [Bet] {
        return storage.getAllBets()
    }

    func placeBet(_ bet: Bet) {
        storage.addBet(bet)
        analyticsUseCase.logEvent(
            .cart(.add),
            parameters: [
                "id": bet.event.id,
                "name": bet.event.displayTitle,
                "value": bet.odd.label.rawValue
            ]
        )
    }

    func removeBetForEvent(id: String) {
        storage.removeBetForEvent(id: id)
        analyticsUseCase.logEvent(
            .cart(.remove),
            parameters: [
                "id": id
            ]
        )
    }

    func getBetForEvent(id: String) -> Bet? {
        return storage.getBetForEvent(id: id)
    }
}
