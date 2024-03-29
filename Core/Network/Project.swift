//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/01/28.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.create(name: "Network",
                             products: [.staticLibrary, .unitTests],
                             dependencies: [
                                .Project.Core.model
                             ])
