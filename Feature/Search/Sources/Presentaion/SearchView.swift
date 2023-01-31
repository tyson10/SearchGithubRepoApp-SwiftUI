//
//  SearchView.swift
//  Toy
//
//  Created by Taeyoung Son on 2023/01/30.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchQueryStr: String
    @AppStorage("RecentlyQueries") private var recentlyQueries: [String] = []
    
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Github")
        }
        .searchable(text: self.$searchQueryStr,
                    prompt: "Search Repositories")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchQueryStr: .constant(""))
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
