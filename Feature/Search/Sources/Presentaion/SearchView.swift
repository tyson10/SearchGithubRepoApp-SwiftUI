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
                    ForEach(self.recentlyQueries, id: \.self) {
                        RecentSearchesContentView(value: $0)
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
