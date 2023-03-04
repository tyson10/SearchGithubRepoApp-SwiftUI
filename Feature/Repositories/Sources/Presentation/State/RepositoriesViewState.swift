//
//  RepositoriesViewState.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/02/18.
//

import Foundation
import Combine

import Network
import Model

class RepositoriesViewState: ObservableObject {
    @Published var repositories: Repositories?
    @Published var name: String
    @Published var isSheetPresented: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService(),
         name: String = "") {
        self.networkService = networkService
        self.name = name
    }
}

extension RepositoriesViewState {
    func onAppear(repoName: String) {
        self.search(name: repoName)
    }
    
    func optionBtnTapped() {
        self.isSheetPresented.toggle()
    }
}

extension RepositoriesViewState {
    private func search(name: String) {
        self.networkService.request(endPoint: .search(option: .init(name: name)))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: self.setReposiries(with:))
            .store(in: &subscriptions)
    }
    
    private func setReposiries(with result: Repositories) {
        self.repositories = result
    }
}
