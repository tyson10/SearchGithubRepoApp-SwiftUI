//
//  RecentSearchesContentView.swift
//  Search
//
//  Created by Taeyoung Son on 2023/02/02.
//

import SwiftUI

struct RecentSearchesContentView: View {
    private var value: String
    private var deleteAction: ((String) -> Void)?
    
    init(value: String = "",
         deleteAction: ((String) -> Void)? = nil) {
        self.value = value
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack {
            Text(self.value)
            Spacer()
            Button(action: self.delete,
                   label: {
                Image(systemName: "xmark")
                    .tint(Color.gray)
            })
        }
        
    }
    
    func delete() {
        self.deleteAction?(self.value)
    }
}

struct RecentSearchesContentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSearchesContentView()
    }
}
