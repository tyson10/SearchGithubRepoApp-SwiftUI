//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

struct SearchView: View {
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = []
    @State private var searchQueryStr: String = ""
    
    var body: some View {
        NavigationView {
            List(self.recentlyQueries, id: \.self) { query in
                Section(content: {
                    Text(query)
                }, header: {
                    RecentSearchesHeaderView()
                        .textCase(.none)
                })
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

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
