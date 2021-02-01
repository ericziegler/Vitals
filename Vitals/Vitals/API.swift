//
//  API.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/26/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import Foundation

// MARK: - Constants

let BaseURL = "https://zigamajig.com/vitals"
let APISuccessStatus = "success"

typealias RequestCompletionBlock = (_ error: APIError?) -> ()

// MARK: - Enums

enum APIError: Error {

    case jsonParsing
    case invalidRequest
    case unknown
    case custom(message: String)

    var errorDescription: String {
        switch self {
        case .jsonParsing:
            return "Data parsing error."
        case .invalidRequest:
            return "Invalid request."
        case .unknown:
            return "Unknown."
        case .custom(let message):
            return message
        }
    }

}

class API {

    static func buildRequestFor(fileName: String, params: [String : String], forceRefresh: Bool = false) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(BaseURL)/\(fileName)") else {
            return nil
        }

        var queryItems = [URLQueryItem]()
        for (curKey, curValue) in params {
            queryItems.append(URLQueryItem(name: curKey, value: curValue))
        }
        if forceRefresh == true {
            let timestamp = Date().timeIntervalSince1970
            queryItems.append(URLQueryItem(name: "timestamp", value: String(timestamp)))
        }
        urlComponents.queryItems = queryItems

        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = "GET"
            return request
        }

        return nil
    }

    static func buildJSONResponse(data: Data?, error: Error?) -> (JSON?, Error?) {
        var result: (JSON?, Error?)?
        if let error = error {
            result = (nil, APIError.custom(message: error.localizedDescription))
        } else {
            if let data = data {
                guard let json = try? JSON(data: data) else {
                    return (nil, APIError.jsonParsing)
                }
                result = (json, nil)
            } else {
                result = (nil, APIError.jsonParsing)
            }
        }
        if let result = result {
            return result
        } else {
            return (nil, APIError.jsonParsing)
        }
    }

    static func errorWithText(text: String) -> APIError {
        let error = APIError.custom(message: text)
        return error
    }

}
