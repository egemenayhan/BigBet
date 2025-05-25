//
//  MockBetsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import RxSwift
import RxRelay
@testable import BigBet

class MockBetsUseCase: BetsUseCaseProtocol {
    private var storage: MockBetStorage
    private var analyticsUseCase: MockAnalyticsUseCase
    private let disposeBag = DisposeBag()
    
    var totalBetPrice = BehaviorRelay<Double>(value: 0)
    var betsSubject: PublishRelay<[Bet]> {
        return storage.betsSubject
    }
    var betUpdateSubject: PublishRelay<Bet> {
        return storage.betUpdateSubject
    }

    init(storage: MockBetStorage, analyticsUseCase: MockAnalyticsUseCase) {
        self.storage = storage
        self.analyticsUseCase = analyticsUseCase

        storage.betsSubject
            .subscribe(onNext: { [weak self] bets in
                self?.calculateTotalBetPrice(bets: bets)
            })
            .disposed(by: disposeBag)
    }

    private func calculateTotalBetPrice(bets: [Bet]) {
        let newValue = bets.reduce(1) { $0 * $1.odd.price }
        totalBetPrice.accept(newValue)
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
