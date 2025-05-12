//
//  APIRequest.swift
//  BigBet
//
//  Created by Egemen Ayhan on 9.05.2025.
//

import Foundation

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ParameterEncodingType {
    case url
    case json
}

typealias RequestParameters = [String: Any]

protocol APIRequest {
    associatedtype Response: Decodable

    var method: HTTPMethodType { get }
    var path: String { get }
    var parameters: RequestParameters? { get }
    var encoding: ParameterEncodingType { get }
}
