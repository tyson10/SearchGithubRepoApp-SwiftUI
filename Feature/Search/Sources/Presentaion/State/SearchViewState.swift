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

final class SearchViewState: ObservableObject {
    @AppStorage("RecentlyQueries") var recentlyQueries: [String] = (UserDefaults.standard.array(forKey: "RecentlyQueries") as? [String]) ?? [] {
        didSet {
            setMatchedQueries(with: searchQueryStr)
        }
    }
    @Published var searchQueryStr: String = ""
    @Published var matchedQueries: [String] = []
    @Published var pushActive = false
    
    func search() {
        print("search!", searchQueryStr)
        pushActive = true
        appendRecentlyQuery(value: searchQueryStr)
    }
    
    func search(query: String) {
        print("search!", query)
        self.searchQueryStr = query
        pushActive = true
        appendRecentlyQuery(value: query)
    }
    
    func delete(query: String) {
        recentlyQueries.removeAll(where: { $0 == query })
    }
    
    func appendRecentlyQuery(value: String) {
        recentlyQueries.removeAll(where: { $0 == value })
        recentlyQueries.insert(value, at: 0)
    }
    
    func removeAllQueries() {
        recentlyQueries.removeAll()
    }
    
    func setMatchedQueries(with query: String) {
        matchedQueries = query.isEmpty ? recentlyQueries : recentlyQueries.filter { $0.hasPrefix(query) }
    }
}
