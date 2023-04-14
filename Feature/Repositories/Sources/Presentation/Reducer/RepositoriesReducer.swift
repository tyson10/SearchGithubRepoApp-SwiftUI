//
//  RepositoriesReducer.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/04/12.
//

import Foundation

import Combine

import ComposableArchitecture

import Model
import Network

struct RepositoriesReducer: ReducerProtocol {
    private let networkService: NetworkService
    
    struct State {
        var repositories: Repositories?
        var option: SearchRepoOption
        var isActionSheetPresented: Bool = false
        var isSheetPresented: Bool = false
        var searchOption: SearchOption? = nil
    }
    
    enum Action {
        case search(option: SearchRepoOption)
        case searchNextPage
        case orderOptionChanged(type: RepoOrderType)
        case sortOptionChanged(type: RepoSortType)
        case optionBtnTapped
        case actionSheetBtnTapped(option: SearchOption)
        case setReposiries(result: Result<Repositories, Error>)
        case setReposiriesOption(result: Result<(Repositories, SearchRepoOption), Error>)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        var task: EffectTask<Action> = .none
        
        switch action {
        case .search(let option):
            task = self.search(with: option).catchToEffect(Action.setReposiries(result:))
            
        case .searchNextPage:
            let option = state.option.nextPage()
            task = self.search(with: option).catchToEffect(Action.setReposiries(result:))
            
        case .orderOptionChanged(let order):
            let option = state.option.set(order: order)
            task = self.search(with: option).catchToEffect(Action.setReposiries(result:))
            
        case .sortOptionChanged(let sort):
            let option = state.option.set(sort: sort)
            task = self.search(with: option).catchToEffect(Action.setReposiries(result:))
            
        case .optionBtnTapped:
            state.isActionSheetPresented.toggle()
            
        case .actionSheetBtnTapped(let option):
            state.searchOption = option
            state.isSheetPresented = true
            
        case .setReposiries(.success(let repositories)):
            state.repositories = repositories
            
        case .setReposiries(.failure(let error)):
            print(error)
            
        case .setReposiriesOption(.success(let res)):
            (state.repositories, state.option) = res
            
        case .setReposiriesOption(.failure(let error)):
            print(error)
        }
        
        return task
    }
    
    private func search(with option: SearchRepoOption) -> AnyPublisher<Repositories, any Error> {
        return self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
