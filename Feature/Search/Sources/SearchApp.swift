//
//  SceneDelegate.swift
//  Search
//
//  Created by Taeyoung Son on 2023/01/30.
//

import Foundation

import SwiftUI

import Repositories

@main
struct SearchApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView<RepositoriesView>()
        }
    }
}
