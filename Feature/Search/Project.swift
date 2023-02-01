//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/01/28.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(name: "Search",
                              products: [.staticFramework, .unitTests, .uiTests],
                              dependencies: [
                                .project(target: "Extensions", path: .relativeToRoot("Core/Extensions")),
                                .external(name: "ComposableArchitecture")
                              ],
                              includeDemoApp: true)
