//
//  BetsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation
import Combine

protocol BetsUseCaseProtocol {

    var betsSubject: PassthroughSubject<[Bet], Never> { get } // array updates
    var betUpdateSubject: PassthroughSubject<Bet, Never> { get } // single bet changes
    var totalBetPrice: CurrentValueSubject<Double, Never> { get } // cart total updates

    func getAllBets() -> [Bet]
    func placeBet(_ bet: Bet)
    func removeBetForEvent(id: String)
    func getBetForEvent(id: String) -> Bet?
}

final class BetsUseCase: BetsUseCaseProtocol {

    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let storage: BetStorageProtocol
    private var cancellables: Set<AnyCancellable> = []

    var totalBetPrice = CurrentValueSubject<Double, Never>(0)

    init(storage: BetStorageProtocol, analyticsUseCase: AnalyticsUseCaseProtocol) {
        self.storage = storage
        self.analyticsUseCase = analyticsUseCase

        bindTotalBetPrice()

        let bets = storage.getAllBets()
        calculateTotalBetPrice(bets: bets)
    }

    private func bindTotalBetPrice() {
        storage.betsSubject
            .sink { [weak self] bets in
                guard let self = self else { return }
                calculateTotalBetPrice(bets: bets)
            }
            .store(in: &cancellables)
    }

    private func calculateTotalBetPrice(bets: [Bet]) {
        guard !bets.isEmpty else {
            totalBetPrice.value = 0
            totalBetPrice.send(0)
            return
        }
        totalBetPrice.value = bets.reduce(1) { $0 * $1.odd.price }
        totalBetPrice.send(totalBetPrice.value)
    }

    var betsSubject: PassthroughSubject<[Bet], Never> {
        storage.betsSubject
    }

    var betUpdateSubject: PassthroughSubject<Bet, Never> {
        storage.betUpdateSubject
    }

    func getAllBets() -> [Bet] {
        storage.getAllBets()
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
        storage.getBetForEvent(id: id)
    }
}
