//
//  Bet.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation

struct Bet {
    var event: BetEvent
    var odd: DisplayOutcome
}

extension Bet: Hashable {
    // Assuming there can be only one bet for an event so hash and comparison are based on event id
    func hash(into hasher: inout Hasher) {
        hasher.combine(event.id)
    }

    static func == (lhs: Bet, rhs: Bet) -> Bool {
        lhs.event.id == rhs.event.id
    }
}
