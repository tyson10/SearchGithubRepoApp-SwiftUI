//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

import Extensions

struct SearchView: View {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = []
    @State private var searchQueryStr: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // self.recentlyQueries의 Element는 Identifiable을 준수해야 함.
                    // 기본 상태에선 준수하지 못함.
                    // 'id: \.self' 이 Element들의 해시값으로 구분하도록 함.
                    // 고로, Element는 Hashable이어야 한다.
                    ForEach(self.$recentlyQueries, id: \.self) {
                        RecentSearchesContentView(value: $0.wrappedValue)
                    }
                } header: {
                    RecentSearchesHeaderView()
                        .textCase(.none)
                }
            }
            .navigationTitle("Github")
        }
        .searchable(text: self.$searchQueryStr,
                    prompt: "Search Repositories")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
