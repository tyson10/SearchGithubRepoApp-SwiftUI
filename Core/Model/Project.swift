//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/02/02.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(name: "Model",
                              products: [.staticLibrary],
                              dependencies: [
                                .Project.Core.extensions
                              ])
