//
//  DependencyContainer.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import Foundation

struct DependencyContainer {

    static let shared = DependencyContainer()

    var betDataStorage = BetDataStorage()
}
