//
//  RepositoriesReducer.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/04/12.
//

import Foundation

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
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        var task: EffectTask<Action>
        
        switch action {
        case .search(let option):
            task = self.networkService.request(endPoint: .search(option: option))
                .decode(type: Repositories.self, decoder: JSONDecoder())
                .catchToEffect(Action.setReposiries(result:))
        default:
            task = .none
        }
        
        return task
    }
}
