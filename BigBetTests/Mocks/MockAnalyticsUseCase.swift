//
//  MockAnalyticsUseCase.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

@testable import BigBet

class MockAnalyticsUseCase: AnalyticsUseCaseProtocol {
    
    func logEvent(_ event: AnalyticsEvent, parameters: AnalyticsParameters?) {
        // not in use
    }
}
