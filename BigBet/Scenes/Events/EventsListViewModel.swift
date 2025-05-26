//
//  EventsListViewModel.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import Foundation
import RxSwift
import RxRelay

final class EventsListViewModel {
    let events = BehaviorRelay<[BetEvent]>(value: [])
    let totalBetPrice = BehaviorRelay<Double>(value: 0)
    let updatedEvents = PublishRelay<[BetEvent]>()
    let errorSubject = PublishRelay<String>()

    private let eventsUseCase: EventsUseCaseProtocol
    private let betsUseCase: BetsUseCaseProtocol
    private let disposeBag = DisposeBag()

    init(eventsUseCase: EventsUseCaseProtocol, betsUseCase: BetsUseCaseProtocol) {
        self.eventsUseCase = eventsUseCase
        self.betsUseCase = betsUseCase

        bindBetsUseCase()
    }

    func bindBetsUseCase() {
        betsUseCase.betUpdateSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bet in
                guard let self else { return }
                self.updatedEvents.accept([bet.event])
            })
            .disposed(by: disposeBag)

        betsUseCase.totalBetPrice
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] price in
                guard let self else { return }
                self.totalBetPrice.accept(price)
            })
            .disposed(by: disposeBag)
    }

    func fetchEvents() {
        Task {
            do {
                let fetchedEvents = try await self.eventsUseCase.fetchEvents()
                self.events.accept(fetchedEvents)
            } catch {
                print("Error fetching events: \(error)")
                errorSubject.accept(error.localizedDescription)
            }
        }
    }

    func filterEvents(for text: String) -> [BetEvent] {
        if text.isEmpty {
            return events.value
        } else {
            return events.value.filter {
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
