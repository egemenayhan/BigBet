//
//  OddsRequest.swift
//  BigBet
//
//  Created by Egemen Ayhan on 10.05.2025.
//

import Foundation

struct OddsRequest: APIRequest {

    typealias Response = [BetEvent]

    let sportKey: String
    let from: Date = Date()

    var method: HTTPMethodType = .get
    var path: String { "/v4/sports/\(sportKey)/odds/" }
    var parameters: RequestParameters?
    var encoding: ParameterEncodingType = .url

    init(sportKey: String) {
        self.sportKey = sportKey

        parameters = [
            "commenceTimeFrom": Date().ISO8601Format(),
            "regions": "eu",
            "markets": "h2h",
            "oddsFormat": "decimal",
            "dateFormat": "iso"
        ]
    }
}
