//
//  NetworkCache.swift
//  Model
//
//  Created by Taeyoung Son on 2023/05/17.
//

import Foundation

public final class NetworkCache {
    public static let shared = NetworkCache()
    
    private let cache = URLCache()
    
    public func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return cache.cachedResponse(for: request)
    }
    
    public func storeCachedResponse(_ response: CachedURLResponse, for request: URLRequest) {
        cache.storeCachedResponse(response, for: request)
    }
}
