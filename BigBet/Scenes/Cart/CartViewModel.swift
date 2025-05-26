//
//  CartViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation
import RxSwift
import RxRelay

@MainActor
final class CartViewModel {
    let bets = BehaviorRelay<[Bet]>(value: [])
    private(set) var totalBetPrice: Double = 0
    
    private let betsUseCase: BetsUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(betsUseCase: BetsUseCaseProtocol) {
        self.betsUseCase = betsUseCase
        bind()
        
        bets.accept(betsUseCase.getAllBets())
        totalBetPrice = betsUseCase.totalBetPrice.value
    }

    private func bind() {
        betsUseCase.betsSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newBets in
                self?.bets.accept(newBets)
            })
            .disposed(by: disposeBag)

        betsUseCase.totalBetPrice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] price in
                guard let self else { return }
                self.totalBetPrice = price
            })
            .disposed(by: disposeBag)
    }

    func removeBet(at index: Int) {
        guard index >= 0 && index < (bets.value.count) else { return }
        let betToRemove = bets.value[index]
        betsUseCase.removeBetForEvent(id: betToRemove.event.id)
    }

    func removeBet(id: String) {
        betsUseCase.removeBetForEvent(id: id)
    }
}
