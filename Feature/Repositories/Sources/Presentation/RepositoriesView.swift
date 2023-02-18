import SwiftUI
import Combine

import Network
import Model

public struct RepositoriesView: View {
    @StateObject private var state = RepositoriesViewState()
    
    public var body: some View {
        List {
            RepositoryRow()
        }
        .onAppear {
            self.state.search(name: "swift")
        }
    }
}

struct RepositoriesView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView()
    }
}
