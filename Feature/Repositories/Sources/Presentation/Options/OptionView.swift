//
//  OptionView.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/25.
//

import SwiftUI

import Model

public struct OptionView<T: QueryParamType>: View {
    @State private var options: [T]
    @Binding private var isPresented: Bool
    // 순환 참조 문제 없는지 확인 필요
    private var selectAction: ((T) -> Void)?
    
    init(options: [T] = [],
         isPresented: Binding<Bool> = .constant(false),
         selectAction: ((T) -> Void)? = nil) {
        self._options = .init(initialValue: options)
        self._isPresented = isPresented
        self.selectAction = selectAction
    }
    
    public var body: some View {
        NavigationView {
            List(self.options) { option in
                Button(action: {
                    self.selectAction?(option)
                    self.isPresented = false
                }, label: {
                    Text(option.stringValue)
                        .foregroundColor(.black)
                })
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
        OptionView(options: SortParam.allCases)
    }
}

