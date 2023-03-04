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
    @Binding private var isPresented: Bool
    
    init(options: [T] = [],
         isPresented: Binding<Bool> = .constant(false)) {
        self.options = options
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            List(self.options) {
                Text($0.stringValue)
            }
            .navigationTitle(T.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cancel") {
                    self.isPresented = false
                }
            }
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView(options: RepoSortType.allCases)
    }
}

