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

final class RepositoriesViewState: ObservableObject {
    @Published var repositories: Repositories?
    @Published var option: SearchRepoOption
    @Published var isActionSheetPresented: Bool = false
    @Published var isSheetPresented: Bool = false
    @Published var searchOption: SearchOption? = nil
    
    var subscriptions = Set<AnyCancellable>()
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService(),
         option: SearchRepoOption = .init(name: "")) {
        self.networkService = networkService
        self.option = option
    }
}

extension RepositoriesViewState {
    func search(option: SearchRepoOption) {
        self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: self.setReposiries(with:))
            .store(in: &subscriptions)
    }
    
    func searchNextPage() {
        let option = self.option.nextPage()
        
        self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                self?.repositories?.items.append(contentsOf: $0.items)
                self?.option = option
            })
            .store(in: &subscriptions)
    }
    
    func orderOptionChanged(with order: RepoOrderType) {
        let option = self.option.set(order: order)
        
        self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                self?.repositories = $0
                self?.option = option
            })
            .store(in: &subscriptions)
    }
    
    func sortOptionChanged(with sort: RepoSortType) {
        let option = self.option.set(sort: sort)
        
        self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in
                self?.repositories = $0
                self?.option = option
            })
            .store(in: &subscriptions)
    }
    
    func optionBtnTapped() {
        self.isActionSheetPresented.toggle()
    }
    
    func actionSheetBtnTapped(option: SearchOption) {
        self.searchOption = option
        self.isSheetPresented = true
    }
    
    private func setReposiries(with result: Repositories) {
        self.repositories = result
    }
}

extension RepositoriesViewState {
    enum SearchOption {
        case order, sort
    }
}
