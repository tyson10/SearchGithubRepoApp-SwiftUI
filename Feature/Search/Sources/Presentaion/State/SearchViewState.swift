//
//  SearchViewState.swift
//  Search
//
//  Created by Taeyoung Son on 2023/02/15.
//

import SwiftUI
import Combine

import Network

class SearchViewState: ObservableObject {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = []
    @Published private var searchQueryStr: String = ""
    @Published private var matchedQueries: [String] = []
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
}
