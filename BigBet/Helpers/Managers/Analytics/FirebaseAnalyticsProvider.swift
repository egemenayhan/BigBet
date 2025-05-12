//
//  FirebaseAnalyticsProvider.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import FirebaseAnalytics

class FirebaseAnalyticsProvider: AnalyticsProviderProtocol {

    func logEvent(_ event: AnalyticsEvent, parameters: AnalyticsParameters?) {
        switch event {
        case .event(let subEvent):
            switch subEvent {
            case .detailTap:
                logDetailTapEvent(parameters: parameters)
            }
        case .cart(let subEvent):
            switch subEvent {
            case .add:
                logCartAddEvent(parameters: parameters)
            case .remove:
                logCartRemoveEvent(parameters: parameters)
            }
        case .generic(let eventName):
            // In case we dont need any spesific actions to send event
            Analytics.logEvent(eventName, parameters: parameters)
        }
    }

    // Events with custom actions such as provider specific event/parameter names for better tracking

    private func logDetailTapEvent(parameters: AnalyticsParameters? = nil) {
        Analytics.logEvent(AnalyticsEventSelectItem, parameters: [
            AnalyticsParameterItemID: parameters?["id"] ?? ""
        ])
    }

    private func logCartAddEvent(parameters: AnalyticsParameters? = nil) {
        Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
            AnalyticsParameterItemID: parameters?["id"] ?? "",
            AnalyticsParameterItemName: parameters?["name"] ?? "",
            AnalyticsParameterValue: parameters?["value"] ?? ""
        ])
    }

    private func logCartRemoveEvent(parameters: AnalyticsParameters? = nil) {
        Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: [
            AnalyticsParameterItemID: parameters?["id"] ?? ""
        ])
    }
}
