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
    
    public init(network: NetworkService) {
        self.networkService = network
    }
    
    struct State: Equatable {
        var repositories: Repositories?
        var option: SearchOption
        var isActionSheetPresented: Bool = false
        var isSheetPresented: Bool = false
        var queryParamMenu: QueryParamMenu? = nil
    }
    
    enum Action {
        case search(option: SearchOption)
        case searchNextPage
        case orderOptionChanged(type: OrderParam)
        case sortOptionChanged(type: SortParam)
        case optionBtnTapped
        case actionSheetBtnTapped(option: QueryParamMenu)
        case setReposiries(result: Result<Repositories, Error>)
        case setReposiriesOption(result: Result<(Repositories, SearchOption), Error>)
        case appendReposiriesOption(result: Result<(Repositories, SearchOption), Error>)
        case none
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        var task: EffectTask<Action> = .none
        
        switch action {
        case .search(let option):
            task = self.search(with: option)
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.setReposiries(result:))
            
        case .searchNextPage:
            let option = state.option.nextPage()
            task = self.search(with: option)
                .tryMap({ ($0, option) })
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.appendReposiriesOption(result:))
            
        case .orderOptionChanged(let order):
            let option = state.option.set(order: order)
            task = self.search(with: option)
                .tryMap({ ($0, option) })
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.setReposiriesOption(result:))
            
        case .sortOptionChanged(let sort):
            let option = state.option.set(sort: sort)
            task = self.search(with: option)
                .tryMap({ ($0, option) })
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.setReposiriesOption(result:))
            
        case .optionBtnTapped:
            state.isActionSheetPresented.toggle()
            
        case .actionSheetBtnTapped(let option):
            state.queryParamMenu = option
            state.isSheetPresented = true
            
        case .setReposiries(.success(let repositories)):
            state.repositories = repositories
            
        case .setReposiries(.failure(let error)):
            print(error)
            
        case .setReposiriesOption(.success(let res)):
            (state.repositories, state.option) = res
            state.isSheetPresented = false
            
        case .setReposiriesOption(.failure(let error)):
            print(error)
            
        case .appendReposiriesOption(.success(let res)):
            state.repositories?.items.append(contentsOf: res.0.items)
            state.option = res.1
            
        case .appendReposiriesOption(.failure(let error)):
            print(error)
        default: break
        }
        
        return task
    }
    
    private func search(with option: SearchOption) -> AnyPublisher<Repositories, any Error> {
        return self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
