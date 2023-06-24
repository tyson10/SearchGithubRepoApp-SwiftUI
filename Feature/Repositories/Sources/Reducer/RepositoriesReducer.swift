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
    private var scheduler: some Scheduler = DispatchQueue.main
    
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
            task = .init(
                search(with: option)
                    .receive(on: scheduler)
                    .tryMap(Action.setRepos)
                    .catch { Just(.handleError($0)) }
            )
            
            /// EffectTask.run 예제. Swift Concurrency와 함꼐 활용.
//            task = .run(operation: {
//                try await $0(.setRepos(search(with: option)))
//            }, catch: { error, send in
//                await send(.handleError(error))
//            })
            
        case .searchNextPage:
            let option = state.option.nextPage()
            
            task = .init(
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: scheduler)
                    .tryMap(Action.append(repos:option:))
                    .catch { Just(.handleError($0)) }
            )
            
        case .orderOptionChanged(let order):
            let option = state.option.set(order: order)
            
            task = .init(
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: scheduler)
                    .tryMap(Action.set(repos:option:))
                    .catch { Just(.handleError($0)) }
            )
            
        case .sortOptionChanged(let sort):
            let option = state.option.set(sort: sort)
            
            task = .init(
                search(with: option)
                    .tryMap({ ($0, option) })
                    .receive(on: scheduler)
                    .tryMap(Action.set(repos:option:))
                    .catch { Just(.handleError($0)) }
            )
            
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
        return requestSearch(with: option)
            .zip(requestLangColor())
            .tryMap { repos, langColors in
                var repos = repos
                repos.merge(langColors: langColors)
                return repos
            }
            .eraseToAnyPublisher()
    }
    
    private func requestSearch(with option: SearchOption) -> AnyPublisher<Repositories, any Error> {
        return self.networkService.request(endPoint: .search(option: option))
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    private func requestLangColor() -> AnyPublisher<LanguageColors, any Error> {
        return self.networkService.request(endPoint: .langColor)
            .decode(type: LanguageColors.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: async-let
extension RepositoriesReducer {
    private func search(with option: SearchOption) async throws -> Repositories {
        // child task 생성하고 placeholder(colors)와 바인딩 후에 지나감. 실제 request는 child task 에서 수행됨.
        async let colors: LanguageColors = networkService.request(endPoint: .langColor)
        // child task 결과와 상관없이 parent task는 계속 실행됨.
        var repos: Repositories = try await networkService.request(endPoint: .search(option: option))
        
        // child task의 colors 값이 필요하므로 child task가 완료될 떄까지 기다림.
        repos.merge(langColors: try await colors)
        
        return repos
    }
}
