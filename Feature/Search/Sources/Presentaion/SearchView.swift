//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

import Extensions
import Repositories

struct SearchView<ResultView: View>: View {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = (UserDefaults.standard.array(forKey: "RecentlyQueries") as? [String]) ?? []
    @State private var searchQueryStr: String = ""
    @State private var matchedQueries: [String] = []
    @State private var pushActive = false

    private var resultViewMaker: ((String) -> ResultView)?
    
    var body: some View {
        NavigationStack {
            NavigationView {
                List {
                    Section {
                        // self.recentlyQueries의 Element는 Identifiable을 준수해야 함.
                        // 기본 상태에선 준수하지 못함.
                        // 'id: \.self' 이 Element들의 해시값으로 구분하도록 함.
                        // 고로, Element는 Hashable이어야 한다.
                        ForEach($matchedQueries, id: \.self) {
                            RecentSearchesContentView(value: $0.wrappedValue,
                                                      deleteAction: delete(query:))
                        }
                    } header: {
                        RecentSearchesHeaderView()
                            .textCase(.none)
                    }
                }
                .navigationTitle("Github")
            }
            .onAppear {
                matchedQueries = recentlyQueries.filter { $0.hasPrefix(self.searchQueryStr) }
            }
            .searchable(text: $searchQueryStr,
                        prompt: "Search Repositories")
            .onChange(of: searchQueryStr) { newValue in
                matchedQueries = recentlyQueries.filter { $0.hasPrefix(newValue) }
            }
            .onSubmit(of: .search) {
                print("search!", self.searchQueryStr)
                self.pushActive = true
                self.appendRecentlyQuery(value: self.searchQueryStr)
            }
            .navigationDestination(isPresented: self.$pushActive) {
                // FIXME: View를 외부에서 주입받도록 수정
                self.resultViewMaker?(self.searchQueryStr)
            }
        }
    }
    
    private func delete(query: String) {
        self.recentlyQueries.removeAll(where: { $0 == query })
        print(self.recentlyQueries)
    }
    
    private func appendRecentlyQuery(value: String) {
        self.recentlyQueries.removeAll(where: { $0 == value })
        self.recentlyQueries.insert(value, at: 0)
        print(self.recentlyQueries)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView<RepositoriesView>()
    }
}
