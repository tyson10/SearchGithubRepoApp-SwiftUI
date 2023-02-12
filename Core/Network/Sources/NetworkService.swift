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
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    func request(endPoint: EndPoint) -> AnyPublisher<Data, NetworkError> {
        guard let request = endPoint.request else {
            return Fail(error: NetworkError.emptyRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidRequest
                }
                return data
            }
            .mapError { error -> NetworkError in
                return .unknown(error: error)
            }
            .eraseToAnyPublisher()
    }
}
