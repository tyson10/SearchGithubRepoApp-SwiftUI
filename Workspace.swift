//
//  Workspace.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/01/28.
//

import ProjectDescription

let workspace = Workspace(
    name: "SearchGithubRepoAppSwiftUI",
    projects: [
        "App/**",
        "Feature/**",
        "Core/**"
    ]
)
