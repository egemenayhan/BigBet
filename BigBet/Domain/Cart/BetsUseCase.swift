//
//  BetsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation
import RxSwift
import RxRelay

protocol BetsUseCaseProtocol {
    var betsSubject: PublishRelay<[Bet]> { get } // array updates
    var betUpdateSubject: PublishRelay<Bet> { get } // single bet changes
    var totalBetPrice: BehaviorRelay<Double> { get } // cart total updates
    
    func getAllBets() -> [Bet]
    func placeBet(_ bet: Bet)
    func removeBetForEvent(id: String)
    func getBetForEvent(id: String) -> Bet?
}

final class BetsUseCase: BetsUseCaseProtocol {
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private let storage: BetStorageProtocol
    private let disposeBag = DisposeBag()
    
    var totalBetPrice = BehaviorRelay<Double>(value: 0)
    
    init(storage: BetStorageProtocol, analyticsUseCase: AnalyticsUseCaseProtocol) {
        self.storage = storage
        self.analyticsUseCase = analyticsUseCase
        
        bindTotalBetPrice()
        
        let bets = storage.getAllBets()
        calculateTotalBetPrice(bets: bets)
    }
    
    private func bindTotalBetPrice() {
        storage.betsSubject
            .subscribe(onNext: { [weak self] bets in
                guard let self = self else { return }
                self.calculateTotalBetPrice(bets: bets)
            })
            .disposed(by: disposeBag)
    }
    
    private func calculateTotalBetPrice(bets: [Bet]) {
        guard !bets.isEmpty else {
            totalBetPrice.accept(0)
            return
        }
        let total = bets.reduce(1) { $0 * $1.odd.price }
        totalBetPrice.accept(total)
    }
    
    var betsSubject: PublishRelay<[Bet]> {
        storage.betsSubject
    }
    
    var betUpdateSubject: PublishRelay<Bet> {
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
