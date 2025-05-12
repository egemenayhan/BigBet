//
//  AnalyticsManager.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation

enum AnalyticsEvent {

    case event(Event)
    case cart(Cart)
    case generic(String) // To feed any event not needed to be defined specifically

    enum Event: String {
        case detailTap = "EventDetailTap"
    }

    enum Cart: String {
        case add
        case remove
    }
}

typealias AnalyticsParameters = [String: Any]

protocol AnalyticsUseCaseProtocol {

    func logEvent(_ event: AnalyticsEvent, parameters: AnalyticsParameters?)
}

protocol AnalyticsProviderProtocol {

    func logEvent(_ event: AnalyticsEvent, parameters: AnalyticsParameters?)
}

class AnalyticsUseCase: AnalyticsUseCaseProtocol {

    // To feeed multiple providers
    private let providers: [AnalyticsProviderProtocol]

    init(providers: [AnalyticsProviderProtocol]) {
        self.providers = providers
    }

    func logEvent(_ event: AnalyticsEvent, parameters: AnalyticsParameters? = nil) {
        providers.forEach { $0.logEvent(event, parameters: parameters) }
    }
}
