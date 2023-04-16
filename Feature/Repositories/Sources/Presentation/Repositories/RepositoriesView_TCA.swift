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
                                    isPresented: viewStore.binding(get: \.isActionSheetPresented, send: .optionBtnTapped),
                                    actions: {
                    Button("Sort") {
                        viewStore.send(.actionSheetBtnTapped(option: .sort))
                    }
                    Button("Order") {
                        viewStore.send(.actionSheetBtnTapped(option: .order))
                    }
                    Button("Cancel") { }
                })
//                .actionSheet(isPresented: viewStore.binding(get: \.isActionSheetPresented, send: .optionBtnTapped),
//                             content: EmptyView())
            }
            .sheet(isPresented: viewStore.binding(get: \.isSheetPresented, send: .none)) {
                switch viewStore.queryParamMenu {
                case .sort:
                    OptionView(options: SortParam.allCases,
                               isPresented: viewStore.binding(get: \.isSheetPresented, send: .none),
                               selectAction: { viewStore.send(.sortOptionChanged(type: $0)) })
                case .order:
                    OptionView(options: OrderParam.allCases,
                               isPresented: viewStore.binding(get: \.isSheetPresented, send: .none),
                               selectAction: { viewStore.send(.orderOptionChanged(type: $0)) })
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    // TODO: Composable Architecture 에 actionSheet 액션 존재. 검토 및 적용 필요.
//    private func actionSheet() -> ActionSheet {
//        let title = Text("Search options")
//        let sort = ActionSheet.Button.default(Text("Sort")) {
//            self.state.actionSheetBtnTapped(option: .sort)
//        }
//        let order = ActionSheet.Button.default(Text("Order")) {
//            self.state.actionSheetBtnTapped(option: .order)
//        }
//        let cancel = ActionSheet.Button.cancel(Text("Cancel"))
//
//        return .init(title: title, buttons: [sort, order, cancel])
//    }
//
//    private func lastItemAppeared() {
//        self.state.searchNextPage()
//    }
}

struct RepositoriesView_TCA_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView_TCA(networkService: NetworkService(), searchWord: "swift")
    }
}
