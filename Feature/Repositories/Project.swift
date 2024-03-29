//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/02/04.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.create(name: "Repositories",
                             products: [.staticFramework, .unitTests, .uiTests],
                             dependencies: [
                                .Project.Common.ui,
                                .ThirdParty.composableArchitecture
                             ],
                             includeDemoApp: true)
