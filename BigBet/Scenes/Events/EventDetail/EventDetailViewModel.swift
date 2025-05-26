//
//  EventDetailViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation
import RxSwift
import RxRelay

@MainActor
final class EventDetailViewModel {
    let selectedOddIndex = BehaviorRelay<Int?>(value: nil)
    let event: BetEvent

    private let betsUseCase: BetsUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(event: BetEvent, betsUseCase: BetsUseCaseProtocol) {
        self.event = event
        self.betsUseCase = betsUseCase

        if let bet = betsUseCase.getBetForEvent(id: event.id),
           let index = event.odds.firstIndex(of: bet.odd) {
            selectedOddIndex.accept(index)
        }
    }

    func placeBet(oddIndex: Int) {
        betsUseCase.placeBet(Bet(event: event, odd: event.odds[oddIndex]))
        selectedOddIndex.accept(oddIndex)
    }

    func removeBet() {
        betsUseCase.removeBetForEvent(id: event.id)
        selectedOddIndex.accept(nil)
    }

    func getEvent() -> BetEvent {
        return event
    }
}
