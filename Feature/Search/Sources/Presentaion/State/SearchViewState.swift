//
//  SearchViewState.swift
//  Search
//
//  Created by Taeyoung Son on 2023/02/15.
//

import SwiftUI
import Combine

import Network
import Model

class SearchViewState: ObservableObject {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = []
    @Published private var searchQueryStr: String = ""
    @Published private var matchedQueries: [String] = []
    
    private let networkService: NetworkService
    
    var subscriptions = Set<AnyCancellable>()
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func search(name: String) {
        self.networkService.request(endPoint: .search(option: .init(name: name)))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .sink { completion in
                print("completion: \(completion)")
            } receiveValue: { repos in
                print("repos: \(repos)")
            }
            .store(in: &subscriptions)
        
        // TODO: subscriptions에 누적되어 메모리 누수 있을것으로 예상되므로 확인 필요
//        print("count: \(self.subscriptions.count)")
    }
}
