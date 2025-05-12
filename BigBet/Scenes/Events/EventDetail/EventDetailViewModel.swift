//
//  EventDetailViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation
import Combine

@MainActor
final class EventDetailViewModel {

    @Published var selectedOddIndex: Int?

    let event: BetEvent

    private let betsUseCase: BetsUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(event: BetEvent, betsUseCase: BetsUseCaseProtocol) {
        self.event = event
        self.betsUseCase = betsUseCase

        if let bet = betsUseCase.getBetForEvent(id: event.id),
           let index = event.odds.firstIndex(of: bet.odd) {
            selectedOddIndex = index
        }
    }

    func placeBet(oddIndex: Int) {
        betsUseCase.placeBet(Bet(event: event, odd: event.odds[oddIndex]))
        selectedOddIndex = oddIndex
    }

    func removeBet() {
        betsUseCase.removeBetForEvent(id: event.id)
        selectedOddIndex = nil
    }
}
