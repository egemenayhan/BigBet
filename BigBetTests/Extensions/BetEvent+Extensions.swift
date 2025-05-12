//
//  BetEvent+Extensions.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

@testable import BigBet
import Foundation

extension BetEvent {

    static func mock(id: String = "mock_event_id", homeTeam: String = "Home Team", awayTeam: String = "Away Team") -> BetEvent {
        BetEvent.init(
            id: id,
            sportKey: "soccer_turkey_super_league",
            sportTitle: "Turkey Super League",
            commenceTime: Date(),
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            bookmakers: [],
            h2hOutcomes: [],
            odds:[
                DisplayOutcome(label: .home, teamName: "Home Team", price: 1.5),
                DisplayOutcome(label: .draw, teamName: "Draw", price: 3.0),
                DisplayOutcome(label: .away, teamName: "Away Team", price: 2.5)
            ]
        )
    }
}
