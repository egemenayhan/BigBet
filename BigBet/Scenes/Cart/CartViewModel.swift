//
//  CartViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation
import Combine

@MainActor
final class CartViewModel {

    private let betsUseCase: BetsUseCaseProtocol

    @Published var bets: [Bet] = []

    private(set) var totalBetPrice: Double = 0
    private var cancellables: Set<AnyCancellable> = []

    init(betsUseCase: BetsUseCaseProtocol) {
        self.betsUseCase = betsUseCase

        bind()

        bets = betsUseCase.getAllBets()
        totalBetPrice = betsUseCase.totalBetPrice.value
    }

    private func bind() {
        betsUseCase.betsSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$bets)

        betsUseCase.totalBetPrice
            .receive(on: RunLoop.main)
            .sink { [weak self] price in
                guard let self else { return }
                self.totalBetPrice = price
            }
            .store(in: &cancellables)
    }

    func removeBet(at index: Int) {
        guard index >= 0 && index < bets.count else { return }
        
        let betToRemove = bets[index]
        
        betsUseCase.removeBetForEvent(id: betToRemove.event.id)
    }

    func removeBet(id: String) {
        betsUseCase.removeBetForEvent(id: id)
    }
}
