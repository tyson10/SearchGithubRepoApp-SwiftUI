//
//  NetworkService.swift
//  Network
//
//  Created by Taeyoung Son on 2023/02/05.
//

import Foundation

import Combine

final public class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    func request<T: Codable>(request: URLRequest) -> AnyPublisher<T, NetworkError> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> T in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidRequest
                }
                return try JSONDecoder().decode(T.self, from: data)
            }
            .mapError { error -> NetworkError in
                return .unknown(error: error)
            }
            .eraseToAnyPublisher()
    }
}
