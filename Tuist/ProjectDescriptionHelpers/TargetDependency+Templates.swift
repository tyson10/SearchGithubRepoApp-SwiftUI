//
//  TargetDependency+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by Taeyoung Son on 2023/02/02.
//

import ProjectDescription

extension TargetDependency {
    public struct Project {
        public struct Core { }
        public struct Feature { }
    }
    
    public struct ThirdParty { }
}

// MARK: - Core
public extension TargetDependency.Project.Core {
    static var api: TargetDependency {
        .project(target: "API", path: .relativeToRoot("Core/API"))
    }
    
    static var extensions: TargetDependency {
        .project(target: "Extensions", path: .relativeToRoot("Core/Extensions"))
    }
    
    static var model: TargetDependency {
        .project(target: "Model", path: .relativeToRoot("Core/Model"))
    }
}

// MARK: - Feature
public extension TargetDependency.Project.Feature {
    static var search: TargetDependency {
        .project(target: "Search", path: .relativeToRoot("Feature/Search"))
    }
}

// MARK: - Third Party
public extension TargetDependency.ThirdParty {
    static var composableArchitecture: TargetDependency {
        .external(name: "ComposableArchitecture")
    }
}
