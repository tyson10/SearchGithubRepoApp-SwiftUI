//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

import Extensions
import CommonUI

public struct SearchView<ResultView: SearchResultView>: View {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = (UserDefaults.standard.array(forKey: "RecentlyQueries") as? [String]) ?? [] {
        didSet {
            setMatchedQueries(with: searchQueryStr)
        }
    }
    @State private var searchQueryStr: String = ""
    @State private var matchedQueries: [String] = []
    @State private var pushActive = false

    private var resultViewMaker: ((String) -> ResultView)?
    
    public init(resultViewMaker: ((String) -> ResultView)? = nil) {
        self.resultViewMaker = resultViewMaker
    }
    
    public var body: some View {
        NavigationStack {
            NavigationView {
                List {
                    Section {
                        // self.recentlyQueries의 Element는 Identifiable을 준수해야 함.
                        // 기본 상태에선 준수하지 못함.
                        // 'id: \.self' 이 Element들의 해시값으로 구분하도록 함.
                        // 고로, Element는 Hashable이어야 한다.
                        ForEach($matchedQueries, id: \.self) {
                            let query = $0.wrappedValue
                            RecentSearchesContentView(
                                value: query,
                                deleteAction: delete(query:)
                            )
                            .onTapGesture {
                                search(query: query)
                            }
                        }
                    } header: {
                        RecentSearchesHeaderView(clearAction: removeAllQueries)
                            .textCase(.none)
                    }
                }
                .navigationTitle("Github")
            }
            .searchable(text: $searchQueryStr,
                        prompt: "Search Repositories")
            .onAppear {
                setMatchedQueries(with: "")
            }
            .onChange(of: searchQueryStr,
                      perform: setMatchedQueries(with:))
            .onSubmit(of: .search, search)
            .navigationDestination(isPresented: self.$pushActive) {
                resultViewMaker?(searchQueryStr)
            }
        }
    }
    
    private func search() {
        print("search!", searchQueryStr)
        pushActive = true
        appendRecentlyQuery(value: searchQueryStr)
    }
    
    private func search(query: String) {
        print("search!", query)
        self.searchQueryStr = query
        pushActive = true
        appendRecentlyQuery(value: query)
    }
    
    private func delete(query: String) {
        recentlyQueries.removeAll(where: { $0 == query })
    }
    
    private func appendRecentlyQuery(value: String) {
        recentlyQueries.removeAll(where: { $0 == value })
        recentlyQueries.insert(value, at: 0)
    }
    
    private func removeAllQueries() {
        recentlyQueries.removeAll()
    }
    
    private func setMatchedQueries(with query: String) {
        matchedQueries = query.isEmpty ? recentlyQueries : recentlyQueries.filter { $0.hasPrefix(query) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView<EmptyView>()
    }
}

extension EmptyView: SearchResultView {
    public init(searchWord: String) {
        self.init()
        print("\(searchWord) 검색")
    }
}
