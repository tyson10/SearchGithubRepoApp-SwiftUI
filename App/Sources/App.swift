//
//  App.swift
//  App
//
//  Created by Taeyoung Son on 2023/03/23.
//

import Foundation

import SwiftUI

import Search
import Repositories

@main
struct SearchRepoApp: App {
    private let searchContainer = SearchDIContainer()
    private let repositoriesContainer = RepositoriesDIContainer()
    
    var body: some Scene {
        WindowGroup {
            searchContainer.makeSearchView(resultViewMaker: repositoriesContainer.makeRepositoriesView(with:))
        }
    } 
}
