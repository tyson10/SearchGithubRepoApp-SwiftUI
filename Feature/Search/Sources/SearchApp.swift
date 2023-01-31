//
//  SceneDelegate.swift
//  Search
//
//  Created by Taeyoung Son on 2023/01/30.
//

import Foundation

import SwiftUI

@main
struct ToyApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(searchQueryStr: .constant(""))
        }
    }
}
