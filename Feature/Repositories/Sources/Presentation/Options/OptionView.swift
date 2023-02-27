//
//  OptionView.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/25.
//

import SwiftUI

import Model

public struct OptionView<T: SearchOptionType>: View {
    @State private var options: [T]
    
    init(options: [T] = []) {
        self.options = options
    }
    
    public var body: some View {
        List(self.options) {
            Text($0.stringValue)
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView(options: RepoSortType.allCases)
    }
}

