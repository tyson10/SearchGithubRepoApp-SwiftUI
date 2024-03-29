//
//  RepositoriesView_TCA.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/04/16.
//

import SwiftUI
import Combine

import ComposableArchitecture

import Model
import CommonUI
import Network

public struct RepositoriesView_TCA: SearchResultView {
    let store: StoreOf<RepositoriesReducer>
    
    public init(networkService: NetworkService, searchWord repoName: String) {
        self.store = .init(
            initialState: .init(option: .init(name: repoName)),
            reducer: RepositoriesReducer(network: networkService)
        )
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.repositories?.items ?? [], id: \.self) { item in
                    RepositoryRow(repository: item)
                        .onAppear() {
                            if viewStore.repositories?.items.last == item {
                                viewStore.send(.searchNextPage)
                            }
                        }
                }
            }
            .onAppear {
                viewStore.send(.search(option: viewStore.option))
            }
            .navigationTitle(viewStore.option.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { viewStore.send(.optionBtnTapped) },
                       label: {
                    Image(systemName: "ellipsis.circle")
                })
                .confirmationDialog("Search options",
                                    isPresented: viewStore.binding(
                                        get: \.isActionSheetPresented,
                                        send: .optionBtnTapped
                                    ),
                                    titleVisibility: .visible,
                                    actions: {
                    Button("Sort") {
                        viewStore.send(.actionSheetBtnTapped(option: .sort))
                    }
                    Button("Order") {
                        viewStore.send(.actionSheetBtnTapped(option: .order))
                    }
                })
            }
            .sheet(isPresented: viewStore.binding(get: \.isSheetPresented, send: .none)) {
                switch viewStore.queryParamMenu {
                case .sort:
                    OptionView(
                        options: SortParam.allCases,
                        isPresented: viewStore.binding(get: \.isSheetPresented, send: .none),
                        selectAction: { viewStore.send(.sortOptionChanged(type: $0)) }
                    )
                case .order:
                    OptionView(
                        options: OrderParam.allCases,
                        isPresented: viewStore.binding(get: \.isSheetPresented, send: .none),
                        selectAction: { viewStore.send(.orderOptionChanged(type: $0)) }
                    )
                case .none:
                    EmptyView()
                }
            }
        }
    }
}

struct RepositoriesView_TCA_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView_TCA(networkService: NetworkService(), searchWord: "swift")
    }
}
