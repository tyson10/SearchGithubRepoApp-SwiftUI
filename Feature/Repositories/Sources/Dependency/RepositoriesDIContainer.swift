//
//  RepositoriesDIContainer.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/04/04.
//

import SwiftUI

import CommonUI
import Network

public final class RepositoriesDIContainer {
    private var networkService: NetworkService = .init()
    
    public init() { }
    
    public func set(networkService: NetworkService) -> Self {
        self.networkService = networkService
        return self
    }
    
    public func makeRepositoriesView(with query: String) -> RepositoriesView {
        return .init(networkService: networkService, searchWord: query)
    }
    
    public func makeRepositoriesView_TCA(with query: String) -> RepositoriesView_TCA {
        return .init(networkService: networkService, searchWord: query)
    }
}
