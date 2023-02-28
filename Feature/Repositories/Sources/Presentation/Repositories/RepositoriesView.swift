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
                Button(action: {
                    
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
            }
        }
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(repoName: "swift")
    }
}
