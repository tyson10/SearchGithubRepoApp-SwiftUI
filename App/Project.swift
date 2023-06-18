//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/01/28.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.create(name: "App",
                             products: [.app, .unitTests, .uiTests],
                             dependencies: [
                                .Project.Feature.search,
                                .Project.Feature.repositories
                             ])
