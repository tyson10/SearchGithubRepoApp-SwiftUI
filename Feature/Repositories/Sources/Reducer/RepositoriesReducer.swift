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
        case setRepos(Repositories)
        case set(repos: Repositories, option: SearchOption)
        case append(repos: Repositories, option: SearchOption)
        case none
        case handleError(Error)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        var task: EffectTask<Action> = .none
        
        switch action {
        case .search(let option):
            task = .publisher { // EffectTask를 생성하는 3가지 방법중 하나.
                search(with: option)
                    .receive(on: DispatchQueue.main)
                    .tryMap(Action.setRepos)
                    .assertNoFailure() // Failure가 Never여야 하므로 사용, 에러 처리에 대한 공부 필요.
            }
            
        case .searchNextPage:
            let option = state.option.nextPage()
            
            task = .publisher {
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: DispatchQueue.main)
                    .tryMap(Action.append(repos:option:))
                    .catch { Just(.handleError($0)) }
            }
            
        case .orderOptionChanged(let order):
            let option = state.option.set(order: order)
            
            task = .publisher {
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: DispatchQueue.main)
                    .tryMap(Action.set(repos:option:))
                    .catch { Just(.handleError($0)) }
            }
            
        case .sortOptionChanged(let sort):
            let option = state.option.set(sort: sort)
            
            task = .publisher {
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: DispatchQueue.main)
                    .tryMap(Action.set(repos:option:))
                    .catch { Just(.handleError($0)) }
            }
            
        case .optionBtnTapped:
            state.isActionSheetPresented.toggle()
            
        case .actionSheetBtnTapped(let option):
            state.queryParamMenu = option
            state.isSheetPresented = true
            
        case .setRepos(let repos):
            state.repositories = repos
            
        case .set(repos: let repos, option: let option):
            (state.repositories, state.option) = (repos, option)
            state.isSheetPresented = false
            
        case let .append(repos: repos, option: option):
            state.repositories?.items.append(contentsOf: repos.items)
            state.option = option
            
        case let .handleError(error):
            print("검색 에러: \(error)")
            
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
