//
//  EventsListViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import Foundation
import Combine

final class EventsListViewModel {

    @Published var events: [BetEvent] = []
    @Published var totalBetPrice: Double = 0

    var updatedIndexes = PassthroughSubject<[BetEvent], Never>()
    var errorSubject = PassthroughSubject<String, Never>()

    private let eventsUseCase: EventsUseCaseProtocol
    private let betsUseCase: BetsUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []

    init(eventsUseCase: EventsUseCaseProtocol, betsUseCase: BetsUseCaseProtocol) {
        self.eventsUseCase = eventsUseCase
        self.betsUseCase = betsUseCase

        bindBetsUseCase()
    }

    func bindBetsUseCase() {
        betsUseCase.betUpdateSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] bet in
                guard let self else { return }
                self.updatedIndexes.send([bet.event])
            }
            .store(in: &cancellables)
        betsUseCase.totalBetPrice
            .receive(on: RunLoop.main)
            .sink { [weak self] price in
                guard let self else { return }
                self.totalBetPrice = price
            }
            .store(in: &cancellables)
    }

    func fetchEvents() {
        Task {
            do {
                self.events = try await self.eventsUseCase.fetchEvents()
            } catch {
                print("Error fetching events: \(error)")
                errorSubject.send(error.localizedDescription)
            }
        }
    }

    func filterEvents(for text: String) -> [BetEvent] {
        if text.isEmpty {
            return events
        } else {
            return events.filter {
                $0.homeTeam.localizedCaseInsensitiveContains(text) ||
                $0.awayTeam.localizedCaseInsensitiveContains(text)
            }
        }
    }

    func getBetForEvent(id: String) -> Bet? {
        betsUseCase.getBetForEvent(id: id)
    }

    func placeBet(for event: BetEvent, with odd: DisplayOutcome) {
        betsUseCase.placeBet(Bet(event: event, odd: odd))
    }

    func removeBet(for eventID: String) {
        betsUseCase.removeBetForEvent(id: eventID)
    }
}
