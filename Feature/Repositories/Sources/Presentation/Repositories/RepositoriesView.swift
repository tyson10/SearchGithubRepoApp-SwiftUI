import SwiftUI
import Combine

import Network
import Model

public struct RepositoriesView: View {
    @StateObject private var state: RepositoriesViewState
    
    init(repoName: String) {
        self._state = .init(wrappedValue: .init(name: repoName))
    }
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(state.repositories?.items ?? [], id: \.self) { item in
                    RepositoryRow(repository: item)
                }
            }
            .onAppear {
                self.state.onAppear(repoName: self.state.name)
            }
            .navigationTitle(self.state.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: self.state.optionBtnTapped,
                       label: {
                    Image(systemName: "ellipsis.circle")
                })
                .actionSheet(isPresented: self.$state.isActionSheetPresented,
                             content: self.actionSheet)
            }
            .sheet(isPresented: self.$state.isSheetPresented) {
                switch self.state.searchOption {
                case .sort:
                    OptionView(options: RepoSortType.allCases)
                case .order:
                    OptionView(options: RepoOrderType.allCases)
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    private func actionSheet() -> ActionSheet {
        let title = Text("Search options")
        let sort = ActionSheet.Button.default(Text("Sort")) {
            self.state.actionSheetBtnTapped(option:.sort)
        }
        let order = ActionSheet.Button.default(Text("Order")) {
            self.state.actionSheetBtnTapped(option:.order)
        }
        let cancel = ActionSheet.Button.cancel(Text("Cancel"))
        
        return .init(title: title, buttons: [sort, order, cancel])
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(repoName: "swift")
    }
}
