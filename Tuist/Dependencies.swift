//
//  Dependencies.swift
//  Config
//
//  Created by Taeyoung Son on 2023/01/29.
//

import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(swiftPackageManager: [
    .remote(url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "0.50.0"))
])
