//
//  RecentSearchesHeaderView.swift
//  Search
//
//  Created by Taeyoung Son on 2023/01/31.
//

import SwiftUI

struct RecentSearchesHeaderView: View {
    
    var body: some View {
        HStack {
            Text("Recent searches")
            Spacer()
            Button("Clear") {
                
            }
        }
    }
}

struct RecentSearchesHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchesHeaderView()
    }
}
