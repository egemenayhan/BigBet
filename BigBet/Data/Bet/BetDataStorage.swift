//
//  BetDataStorage.swift
//  BigBet
//
//  Created by Egemen Ayhan on 11.05.2025.
//

import Foundation
import Combine

protocol BetStorageProtocol {

    var betsSubject: PassthroughSubject<[Bet], Never> { get } // array changes
    var betUpdateSubject: PassthroughSubject<Bet, Never> { get } // single bet changes

    func getAllBets() -> [Bet]
    func addBet(_ bet: Bet)
    func removeBetForEvent(id: String)
    func getBetForEvent(id: String) -> Bet?
}

final class BetDataStorage: BetStorageProtocol {

    // Used both array and dictionary because I want to provide O(1) complexity for lookups. Array is just for keeping order.
    private var betsArray: [String] = []
    private var betsDictionary: [String: Bet] = [:]

    // to prevent race conditions in data storage
    private let queue = DispatchQueue(label: "BetDataStorageQueue", attributes: .concurrent)

    var betsSubject = PassthroughSubject<[Bet], Never>()
    var betUpdateSubject = PassthroughSubject<Bet, Never>()

    func getAllBets() -> [Bet] {
        queue.sync {
            return betsArray.compactMap { self.betsDictionary[$0] }
        }
    }

    func addBet(_ bet: Bet) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }

            let eventId = bet.event.id

            // If no bet exists, add directly. If replacing, move the bet to the end of the array to keep correct update order.
            if self.betsDictionary[eventId] == nil {
                self.betsDictionary[eventId] = bet
                self.betsArray.append(eventId)
            } else {
                if let index = self.betsArray.firstIndex(of: eventId) {
                    self.betsDictionary[eventId] = bet
                    self.betsArray.move(fromOffsets: [index], toOffset: self.betsArray.endIndex)
                }
            }
            self.publishBets()
            self.publishBetUpdate(for: bet)
        }
    }

    func removeBetForEvent(id: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self, let bet = self.betsDictionary[id] else { return }

            self.betsDictionary[id] = nil
            if let index = self.betsArray.firstIndex(of: id) {
                self.betsArray.remove(at: index)
            }
            self.publishBets()
            self.publishBetUpdate(for: bet)
        }
    }

    func getBetForEvent(id: String) -> Bet? {
        var bet: Bet?
        queue.sync { [weak self] in
            guard let self else { return }
            bet = self.betsDictionary[id]
        }
        return bet
    }

    private func publishBets() {
        queue.async { [weak self] in
            guard let self else { return }
            let updatedBets = self.betsArray.compactMap { self.betsDictionary[$0] }
            self.betsSubject.send(updatedBets)
        }
    }

    private func publishBetUpdate(for bet: Bet) {
        queue.async { [weak self] in
            guard let self else { return }
            self.betUpdateSubject.send(bet)
        }
    }
}


