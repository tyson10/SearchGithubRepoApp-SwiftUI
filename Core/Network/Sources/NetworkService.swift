//
//  NetworkService.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import Foundation

import Combine

final public class NetworkService {
    public typealias ResultPublisher = AnyPublisher<Data, NetworkError>
    
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
    
    public func request(endPoint: EndPoint) -> ResultPublisher {
        guard let request = endPoint.request else {
            return Fail(error: NetworkError.emptyRequest).eraseToAnyPublisher()
        }
        
        var resultPublisher: AnyPublisher<Data, NetworkError>
        
        if let data = cache.cachedResponse(for: request)?.data {
            resultPublisher = cachedResultPublisher(with: data)
        } else {
            resultPublisher = dataTaskPublisher(for: request)
        }
        
        return resultPublisher
    }
    
    private func cachedResultPublisher(with data: Data) -> ResultPublisher {
        return Future<Data, NetworkError> { $0(.success(data)) }.eraseToAnyPublisher()
    }
    
    private func dataTaskPublisher(for request: URLRequest) -> ResultPublisher {
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
