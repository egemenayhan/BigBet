//
//  MockNetworkService.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation
@testable import BigBet

class MockNetworkService: NetworkService {

    var shouldreturnError: Bool = false

    func request<T: APIRequest>(_ request: T) async throws -> T.Response {
        guard !shouldreturnError else {
            throw NSError(domain: "Mock error", code: 0, userInfo: nil)
        }

        // Return mock data for BetEvent
        let mockBetEvent = BetEvent.mock()
        return [mockBetEvent] as! T.Response
    }
}
