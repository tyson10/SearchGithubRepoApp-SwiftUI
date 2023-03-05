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
    // 순환 참조 문제 없는지 확인 필요
    private var selectAction: ((SearchRepoOption) -> Void)?
    
    init(options: [T] = [],
         isPresented: Binding<Bool> = .constant(false),
         selectAction: ((SearchRepoOption) -> Void)? = nil) {
        self.options = options
        self._isPresented = isPresented
        self.selectAction = selectAction
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

