//
//  NetworkManager.swift
//  BigBet
//
//  Created by Egemen Ayhan on 9.05.2025.
//

import Foundation
import Alamofire

protocol NetworkService {

    func request<T: APIRequest>(_ request: T) async throws -> T.Response
}

final class NetworkManager: NetworkService {

    private enum Constants {
        enum ApiKey {
            static let parameterName = "apiKey"
            static let defaultApiKey: String = "607f4d0ce19c6c2973cce75f1cbbb3d4"
        }
    }

    private var adapter: NetworkAdapter
    private let baseURL: String

    init(baseURL: String, adapter: NetworkAdapter, apiKey: String = Constants.ApiKey.defaultApiKey) {
        self.baseURL = baseURL
        self.adapter = adapter

        self.adapter.globalQueryParams[Constants.ApiKey.parameterName] = apiKey
    }

    func request<T: APIRequest>(_ request: T) async throws -> T.Response {
        try await adapter.perform(request, baseURL: baseURL)
    }
}
