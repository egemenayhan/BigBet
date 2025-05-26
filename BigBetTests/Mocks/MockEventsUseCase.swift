//
//  MockEventsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

@testable import BigBet

class MockEventsUseCase: EventsUseCaseProtocol {
    private var networkManager: MockNetworkService
    
    init(networkManager: MockNetworkService) {
        self.networkManager = networkManager
    }

    func fetchEvents() async throws -> [BetEvent] {
        try await networkManager.request(OddsRequest(sportKey: "soccer_turkey_super_league"))
    }
}
