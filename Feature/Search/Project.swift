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
                                .Project.Core.network,
                                .Project.Feature.repositories,
                                .ThirdParty.composableArchitecture
                              ],
                              includeDemoApp: true)
