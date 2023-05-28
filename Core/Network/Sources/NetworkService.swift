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
    
    private func isValid(response: URLResponse?) -> Bool {
        if let httpRes = response as? HTTPURLResponse,
           (200...299).contains(httpRes.statusCode) {
            return true
        } else {
            return false
        }
    }
}

// MARK: - CompletionHandler
extension NetworkService {
    public func request<T: Decodable>(
        endPoint: EndPoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        func decodedResult(with data: Data) -> Result<T, NetworkError> {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(.unknown(error: error))
            }
        }
        
        guard let request = endPoint.request else {
            return completion(.failure(.emptyRequest))
        }
        
        let decoder = JSONDecoder()
        
        if let data = cache.cachedResponse(for: request)?.data {
            completion(decodedResult(with: data))
        } else {
            session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self,
                      self.isValid(response: response),
                      let data = data, let response = response else {
                    completion(.failure(.invalidRequest))
                    return
                }
                
                let cachedData = CachedURLResponse(response: response, data: data)
                
                self.cache.storeCachedResponse(cachedData, for: request)
                
                completion(decodedResult(with: data))
            }
            .resume()
        }
    }
}

// MARK: - Async/await
extension NetworkService {
    public func request<T: Decodable>(endPoint: EndPoint) async throws -> T {
        guard let request = endPoint.request else {
            throw NetworkError.emptyRequest
        }
        
        var resultData: Data
        
        if let data = cache.cachedResponse(for: request)?.data {
            resultData = data
        } else {
            resultData = try await data(for: request)
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: resultData)
        
        return decodedData
    }
    
    private func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        
        guard isValid(response: response) else {
            throw NetworkError.invalidRequest
        }
        
        let cachedData = CachedURLResponse(response: response, data: data)
        
        cache.storeCachedResponse(cachedData, for: request)
        
        return data
    }
}

// MARK: - Combine
extension NetworkService {
    public typealias ResultPublisher = AnyPublisher<Data, NetworkError>
    
    public func request(endPoint: EndPoint) -> ResultPublisher {
        guard let request = endPoint.request else {
            return Fail(error: NetworkError.emptyRequest).eraseToAnyPublisher()
        }
        
        var resultPublisher: ResultPublisher
        
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
                guard let self = self,
                      self.isValid(response: response) else {
                    throw NetworkError.invalidRequest
                }
                
                let cachedData = CachedURLResponse(response: response, data: data)
                
                self.cache.storeCachedResponse(cachedData, for: request)
                
                return data
            }
            .mapError { error -> NetworkError in
                return .unknown(error: error)
            }
            .eraseToAnyPublisher()
    }
}
