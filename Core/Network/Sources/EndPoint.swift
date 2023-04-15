//
//  EndPoint.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

import Model

public enum EndPoint {
    case image(url: String)
    case search(option: SearchOption)
    case langColor
}

public extension EndPoint {
    var request: URLRequest? {
        guard let url = self.url else { return nil }
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

private extension EndPoint {
    var url: URL? {
        let baseUrl = NetworkService.baseUrl
        switch self {
        case.search(let option):
            var urlComp = URLComponents(string: baseUrl.appending("/search/repositories"))!
            let queryItemArray = option.toParameters().map {
                URLQueryItem(name: $0.key, value: .init(describing: $0.value))
            }
            urlComp.queryItems = queryItemArray
            return urlComp.url!
        case .image(let url):
            return URL(string: url)
        case .langColor:
            return URL(string: "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json")
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .search, .image, .langColor:
            return .get
        }
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: [String: String]? {
        return nil
    }
}
