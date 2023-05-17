//
//  NetworkService.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import Foundation

import Combine

final public class NetworkService {
    public static let baseUrl = "https://api.github.com"
    private let session: URLSession
    private let cache: URLCache
    
    public init(session: URLSession = .shared,
                cache: URLCache = .shared
    ) {
        self.session = session
        self.cache = cache
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    public func request(endPoint: EndPoint) -> AnyPublisher<Data, NetworkError> {
        guard let request = endPoint.request else {
            return Fail(error: NetworkError.emptyRequest).eraseToAnyPublisher()
        }
        
        // FIXME: URLCache 동작 확인
        if let data = cache.cachedResponse(for: request)?.data {
            return Just(data)
                .mapError { error -> NetworkError in
                    // FIXME: Warnging 해결
                    return .unknown(error: error)
                }
                .eraseToAnyPublisher()
        } else {
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw NetworkError.invalidRequest
                    }
                    
                    let cachedData = CachedURLResponse(response: response, data: data)
                    
                    self?.cache.storeCachedResponse(cachedData, for: request)
                    
                    return data
                }
                .mapError { error -> NetworkError in
                    return .unknown(error: error)
                }
                .eraseToAnyPublisher()
        }
    }
}
