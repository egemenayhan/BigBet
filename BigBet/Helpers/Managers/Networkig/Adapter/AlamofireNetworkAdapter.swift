//
//  AlamofireNetworkAdapter.swift
//  BigBet
//
//  Created by Egemen Ayhan on 9.05.2025.
//

import Alamofire

final class AlamofireNetworkAdapter: NetworkAdapter {

    var globalQueryParams: [String: String] = [:]

    func perform<T: APIRequest>(_ request: T, baseURL: String) async throws -> T.Response {
        let url = baseURL + request.path

        var mergedParams = request.parameters ?? [:]
                for (key, value) in globalQueryParams {
                    mergedParams[key] = value
                }

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: mapMethod(request.method),
                       parameters: mergedParams,
                       encoding: mapEncoding(request.encoding))
                .validate()
                .responseDecodable(of: T.Response.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    private func mapMethod(_ method: HTTPMethodType) -> HTTPMethod {
        switch method {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }

    private func mapEncoding(_ encoding: ParameterEncodingType) -> ParameterEncoding {
        switch encoding {
            case .url: return URLEncoding.default
            case .json: return JSONEncoding.default
        }
    }
}
