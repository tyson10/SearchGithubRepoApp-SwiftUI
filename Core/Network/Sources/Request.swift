//
//  Request.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/06.
//

import Foundation

import Model

public enum EndPoint {
    case search(option: SearchRepoOption)
}


extension EndPoint {
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
    
    private var url: URL? {
        let baseUrl = NetworkService.baseUrl
        var urlStr: String
        switch self {
        case.search(_):
            urlStr = baseUrl.appending("/search/repositories")
        }
        return URL(string: urlStr)
    }
    
    private var method: HTTPMethod {
        switch self {
        case .search(_):
            return .get
        }
    }
    
    private var body: Data? {
        return nil
    }
    
    private var headers: [String: String]? {
        return nil
    }
}
