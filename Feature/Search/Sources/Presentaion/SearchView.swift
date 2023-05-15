//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

import Extensions
import CommonUI
import Network

public struct SearchView<ResultView: SearchResultView>: View {
    @StateObject private var state = SearchViewState()

    private var resultViewMaker: ((String) -> ResultView)?
    
    public init(resultViewMaker: ((String) -> ResultView)? = nil) {
        self.resultViewMaker = resultViewMaker
    }
    
    public var body: some View {
        NavigationStack {
            NavigationView {
                List {
                    if !state.matchedQueries.isEmpty {
                        Section {
                            // self.recentlyQueries의 Element는 Identifiable을 준수해야 함.
                            // 기본 상태에선 준수하지 못함.
                            // 'id: \.self' 이 Element들의 해시값으로 구분하도록 함.
                            // 고로, Element는 Hashable이어야 한다.
                            ForEach(state.matchedQueries, id: \.self) { query in
                                Button(action: {
                                    state.search(query: query)
                                }, label: {
                                    RecentSearchesContentView(
                                        value: query,
                                        deleteAction: state.delete(query:)
                                    )
                                })
                            }
                        } header: {
                            RecentSearchesHeaderView(clearAction: state.removeAllQueries)
                                .textCase(.none)
                        }
                    }
                }
                .navigationTitle("Github")
            }
            .searchable(
                text: $state.searchQueryStr,
                prompt: "Search Repositories"
            )
            .onChange(
                of: state.searchQueryStr,
                perform: state.setMatchedQueries(with:)
            )
            .onSubmit(of: .search, state.search)
            // TODO: ViewBuilder 두번 호출되는 이유?
            .navigationDestination(isPresented: $state.pushActive) {
                if state.pushActive {
                    resultViewMaker?(state.searchQueryStr)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView<EmptyView>()
    }
}

extension EmptyView: SearchResultView {
    public init(networkService: NetworkService, searchWord: String) {
        self.init()
        print("\(searchWord) 검색")
    }
}
