import SwiftUI
import Combine

import Model
import CommonUI
import Network

public struct RepositoriesView: SearchResultView {
    @StateObject private var state: RepositoriesViewState
    
    public init(networkService: NetworkService, searchWord repoName: String) {
        self._state =
            .init(
                wrappedValue: .init(networkService: networkService, option: .init(name: repoName))
            )
    }
    
    public var body: some View {
        List {
            ForEach(state.repositories?.items ?? [], id: \.self) { item in
                RepositoryRow(repository: item)
                    .onAppear() {
                        if self.state.repositories?.items.last == item {
                            self.lastItemAppeared()
                        }
                    }
            }
        }
        .onAppear {
            self.state.search(option: self.state.option)
        }
        .navigationTitle(self.state.option.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: self.state.optionBtnTapped,
                   label: {
                Image(systemName: "ellipsis.circle")
            })
            .confirmationDialog("Search options",
                                isPresented: self.$state.isActionSheetPresented,
                                titleVisibility: .visible,
                                actions: {
                Button("Sort") {
                    self.state.actionSheetBtnTapped(option: .sort)
                }
                Button("Order") {
                    self.state.actionSheetBtnTapped(option: .order)
                }
            })
        }
        .sheet(isPresented: self.$state.isSheetPresented) {
            switch self.state.queryParamMenu {
            case .sort:
                OptionView(options: SortParam.allCases,
                           isPresented: self.$state.isSheetPresented,
                           selectAction: self.state.sortOptionChanged(with:))
            case .order:
                OptionView(options: OrderParam.allCases,
                           isPresented: self.$state.isSheetPresented,
                           selectAction: self.state.orderOptionChanged(with:))
            case .none:
                EmptyView()
            }
        }
    }
    
    private func lastItemAppeared() {
        self.state.searchNextPage()
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(networkService: NetworkService(), searchWord: "swift")
    }
}
