//
//  Logger.swift
//  HeroNews
//
//  Created by Egemen Ayhan on 2.05.2025.
//


import Foundation

public class Logger {

    static func log(request: URLRequest) {
        //        if !DebugConfig.isEnabled(.networking) { return }
        debugPrint("< - - - - - - - - - - Request Start - - - - - - - - - - >")

        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"

        var output: [NSString] = []
        output.append(urlAsString as NSString)
        output.append(method as NSString)
        output.append("\(path)?\(query)" as NSString)

        output.append("< - - - - - - - - Request Headers Start - - - - - - - - >" as NSString)
        request.allHTTPHeaderFields?.forEach({
            output.append("\($0): \($1)" as NSString)
        })
        output.append("< - - - - - - - - Request Headers End - - - - - - - - >" as NSString)

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8),
           bodyString.count < 100000 {
            output.append("< - - - - - - - - Request Body Start - - - - - - - - >" as NSString)
            output.append(bodyString as NSString)
            output.append("< - - - - - - - - Request Body End - - - - - - - - >" as NSString)
        }

        output.forEach({ debugPrint($0) })
        debugPrint("< - - - - - - - - - - Request End - - - - - - - - - - >")
    }

    static func log(response: HTTPURLResponse, bodyData: Data?) {
        //        if !DebugConfig.isEnabled(.networking) { return }
        debugPrint("< - - - - - - - - - - Response Start - - - - - - - - - - >")
        print("Status: \(response.statusCode)")
        if let bodyData = bodyData {
            debugPrint(bodyData.prettyPrintedJSONString ?? "")
        }
        debugPrint("< - - - - - - - - - - Response End - - - - - - - - - - >")
    }

    static func logData(bodyData: Data?) {
        //        if !DebugConfig.isEnabled(.networking) { return }
        debugPrint("< - - - - - - - - - - Data Response Start - - - - - - - - - - >")
        if let bodyData = bodyData {
            debugPrint(bodyData.prettyPrintedJSONString ?? "")
        }
        debugPrint("< - - - - - - - - - - Data Response End - - - - - - - - - - >")
    }

}

extension Data {
    var prettyPrintedJSONString: NSString? {
        // NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else { return nil }
        if prettyPrintedString.length < 1000000 {
            return prettyPrintedString
        }
        return "Response is too long..."
    }
}
