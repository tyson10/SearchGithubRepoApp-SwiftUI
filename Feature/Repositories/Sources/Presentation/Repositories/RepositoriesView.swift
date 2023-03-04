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
                .actionSheet(isPresented: self.$state.isSheetPresented) {
                    ActionSheet(title: Text("Search options"),
                                buttons: [
                                    .default(Text("Sort")),
                                    .default(Text("Order")),
                                    .cancel(Text("Cancel"))
                                ])
                }
            }
        }
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(repoName: "swift")
    }
}
