//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/01/28.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.create(name: "Search",
                             products: [.staticFramework, .unitTests, .uiTests],
                             dependencies: [
                                .Project.Common.ui,
                                .ThirdParty.composableArchitecture
                             ],
                             includeDemoApp: true)
