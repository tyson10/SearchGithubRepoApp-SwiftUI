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
    
    func request(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
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
