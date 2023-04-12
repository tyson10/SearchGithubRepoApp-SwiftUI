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
    
    struct State {
        var repositories: Repositories?
        var option: SearchRepoOption
        var isActionSheetPresented: Bool = false
        var isSheetPresented: Bool = false
        var searchOption: SearchOption? = nil
    }
    
    
    enum Action {
        
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}
