//
//  RepositoriesDIContainer.swift
//  Repositories
//
//  Created by Taeyoung Son on 2023/04/04.
//

import SwiftUI

import CommonUI

public final class RepositoriesDIContainer{
    public init() { }
    
    public func makeRepositoriesView(with query: String) -> RepositoriesView {
        return .init(searchWord: query)
    }
}
