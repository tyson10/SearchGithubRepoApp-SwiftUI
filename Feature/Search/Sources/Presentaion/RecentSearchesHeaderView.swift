//
//  RecentSearchesHeaderView.swift
//  Search
//
//  Created by Taeyoung Son on 2023/01/31.
//

import SwiftUI

struct RecentSearchesHeaderView: View {
    private var clearAction: () -> Void
    
    init(clearAction: @escaping () -> Void) {
        self.clearAction = clearAction
    }
    
    var body: some View {
        HStack {
            Text("Recent searches")
            Spacer()
            Button("Clear", action: self.clearAction)
        }
    }
}

struct RecentSearchesHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchesHeaderView(clearAction: {})
    }
}
