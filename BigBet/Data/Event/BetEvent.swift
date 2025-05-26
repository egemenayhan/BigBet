//
//  BetEvent.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import Foundation

struct BetEvent: Decodable {

    let id: String
    let sportKey: String
    let sportTitle: String
    let commenceTime: Date
    let homeTeam: String
    let awayTeam: String

    // not in use
    private let h2hOutcomes: [Outcome]
    private let bookmakers: [Bookmaker]

    // extracted odds
    let odds: [DisplayOutcome]

    // Static formatters for better performance - shared across all instances
    static let sharedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = AppConstants.Formatting.shortDateStyle
        formatter.timeStyle = AppConstants.Formatting.shortTimeStyle
        return formatter
    }()

    static let sharedISO8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id
        case sportKey = "sport_key"
        case sportTitle = "sport_title"
        case commenceTime = "commence_time"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case bookmakers
    }

    init(
        id: String,
        sportKey: String,
        sportTitle: String,
        commenceTime: Date,
        homeTeam: String,
        awayTeam: String,
        bookmakers: [Bookmaker],
        h2hOutcomes: [Outcome],
        odds: [DisplayOutcome]
    ) {
        self.id = id
        self.sportKey = sportKey
        self.sportTitle = sportTitle
        self.commenceTime = commenceTime
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.bookmakers = bookmakers
        self.h2hOutcomes = h2hOutcomes
        self.odds = odds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.sportKey = try container.decode(String.self, forKey: .sportKey)
        self.sportTitle = try container.decode(String.self, forKey: .sportTitle)
        self.homeTeam = try container.decode(String.self, forKey: .homeTeam)
        self.awayTeam = try container.decode(String.self, forKey: .awayTeam)
        self.bookmakers = try container.decode([Bookmaker].self, forKey: .bookmakers)

        let timeString = try container.decode(String.self, forKey: .commenceTime)
        guard let parsedDate = Self.sharedISO8601Formatter.date(from: timeString) else {
            throw DecodingError.dataCorruptedError(forKey: .commenceTime,
                in: container,
                debugDescription: "Invalid ISO8601 date format: \(timeString)"
            )
        }
        self.commenceTime = parsedDate


        // Find first valid H2H market with outcomes
        self.h2hOutcomes = bookmakers
            .compactMap { $0.markets.first(where: { $0.key == "h2h" }) }
            .compactMap { $0.outcomes.isEmpty ? nil : $0.outcomes }
            .first ?? []

        // Map MS 1 / X / 2 once
        var mapped: [MSLabel: DisplayOutcome] = [:]

        for outcome in h2hOutcomes {
            if outcome.name == homeTeam {
                mapped[.home] = DisplayOutcome(label: .home, teamName: outcome.name, price: outcome.price)
            } else if outcome.name == awayTeam {
                mapped[.away] = DisplayOutcome(label: .away, teamName: outcome.name, price: outcome.price)
            } else if outcome.name.lowercased() == "draw" {
                mapped[.draw] = DisplayOutcome(label: .draw, teamName: outcome.name, price: outcome.price)
            }
        }

        self.odds = [MSLabel.home, .draw, .away].compactMap { mapped[$0] }
    }
}

extension BetEvent: Hashable {

    static func == (lhs: BetEvent, rhs: BetEvent) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum MSLabel: String, CaseIterable, Codable {
    case home = "MS 1"
    case draw = "MS X"
    case away = "MS 2"
}

struct DisplayOutcome: Codable, Equatable {

    let label: MSLabel
    let teamName: String
    let price: Double
}

struct Bookmaker: Decodable {

    let key: String
    let title: String
    let link: String?
    let sid: String?
    let markets: [Market]

    enum CodingKeys: String, CodingKey {
        case key, title, link, sid, markets
    }
}

struct Market: Decodable {

    let key: String
    let link: String?
    let sid: String?
    let outcomes: [Outcome]

    enum CodingKeys: String, CodingKey {
        case key, link, sid, outcomes
    }
}

struct Outcome: Decodable {

    let name: String
    let price: Double
    let link: String?
    let sid: String?
    let betLimit: Double?

    enum CodingKeys: String, CodingKey {
        case name, price, link, sid
        case betLimit = "bet_limit"
    }
}

