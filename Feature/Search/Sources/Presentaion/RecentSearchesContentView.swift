//
//  RecentSearchesContentView.swift
//  Search
//
//  Created by Taeyoung Son on 2023/02/02.
//

import SwiftUI

struct RecentSearchesContentView: View {
    private var value: String
    
    init(value: String = "") {
        self.value = value
    }
    
    var body: some View {
        HStack {
            Text(self.value)
            Spacer()
            Button(action: {
                
            }, label: {
                Image(systemName: "xmark")
                    .tint(Color.gray)
            })
        }
        
    }
}

struct RecentSearchesContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchesContentView()
    }
}
