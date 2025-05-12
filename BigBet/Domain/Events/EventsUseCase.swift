//
//  EventsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

protocol EventsUseCaseProtocol {

    func fetchEvents() async throws -> [BetEvent]
}

final class EventsUseCase: EventsUseCaseProtocol {

    private enum Constatnts {
        static let sportKey: String = "soccer_turkey_super_league"
    }

    private let networkManager: NetworkService

    init(networkManager: NetworkService) {
        self.networkManager = networkManager
    }

    func fetchEvents() async throws -> [BetEvent] {
        let request = OddsRequest(sportKey: Constatnts.sportKey)
        return try await networkManager.request(request)
    }
}
