//
//  Request.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

import Model

struct RequestBuilder {
    let url: URL
    let method: HTTPMethod
    let body: Data?
    let headers: [String: String]?

    func create() -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        if let body = body {
            request.httpBody = body
        }
        if let headers = headers {
            request.allHTTPHeaderFields = headers
        }
        return request
    }
}

enum EndPoint {
    case search(option: SearchRepoOption)
}
