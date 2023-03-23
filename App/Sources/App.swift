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
    var body: some Scene {
        WindowGroup {
            SearchView<RepositoriesView>() {
                .init(searchWord: $0)
            }
        }
    }
}
