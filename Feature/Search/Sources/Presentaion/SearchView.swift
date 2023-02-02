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
            Spacer().navigationTitle("Github")
        }
        .searchable(text: self.$searchQueryStr,
                    prompt: "Search Repositories")
        .searchSuggestions {
            ForEach(self.$recentlyQueries, id: \.self) {
                RecentSearchesContentView(value: $0.wrappedValue)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
