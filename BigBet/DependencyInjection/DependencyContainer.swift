//
//  DependencyContainer.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation

// Using singleton container to make dependency injection without mess
struct DependencyContainer {

    static let shared = DependencyContainer()

    let betDataStorage = BetDataStorage()
    let analyticsUsecase: AnalyticsUseCaseProtocol = AnalyticsUseCase(
        providers: [FirebaseAnalyticsProvider()]
    )
}
