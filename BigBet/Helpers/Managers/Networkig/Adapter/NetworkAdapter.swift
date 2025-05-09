//
//  NetworkAdapter.swift
//  BigBet
//
//  Created by Egemen Ayhan on 9.05.2025.
//

protocol NetworkAdapter {
    var globalQueryParams: [String: String] { get set }

    func perform<T: APIRequest>(_ request: T, baseURL: String) async throws -> T.Response
}
