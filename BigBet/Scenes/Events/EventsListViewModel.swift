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
    @Published var errorMessage: String?

    private let eventsUseCase: EventsUseCaseProtocol
    private let cancellables: Set<AnyCancellable> = []

    init(eventsUseCase: EventsUseCaseProtocol) {
        self.eventsUseCase = eventsUseCase
    }

    func fetchEvents() {
        Task {
            do {
                self.events = try await self.eventsUseCase.fetchEvents()
            } catch {
                print("Error fetching events: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
