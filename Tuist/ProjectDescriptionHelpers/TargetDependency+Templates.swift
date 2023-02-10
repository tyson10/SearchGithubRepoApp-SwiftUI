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
        public struct Common { }
    }
    
    public struct ThirdParty { }
}

// MARK: - Core
public extension TargetDependency.Project.Core {
    static var network: TargetDependency {
        .project(target: "Network", path: .relativeToRoot("Core/Network"))
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
    
    static var repositories: TargetDependency {
        .project(target: "Repositories", path: .relativeToRoot("Feature/Repositories"))
    }
}

public extension TargetDependency.Project.Common {
    static var ui: TargetDependency {
        .project(target: "CommonUI", path: .relativeToRoot("Common/UI"))
    }
}

// MARK: - Third Party
public extension TargetDependency.ThirdParty {
    static var composableArchitecture: TargetDependency {
        .external(name: "ComposableArchitecture")
    }
}
