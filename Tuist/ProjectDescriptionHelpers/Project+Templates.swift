import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    public static func create(name: String,
                              products: [Product],
                              dependencies: [TargetDependency],
                              includeDemoApp: Bool = false) -> Project {
        let platform = Platform.iOS
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
            ]
        var targets = [Target]()
        var schemes = [Scheme]()
        
        products.forEach {
            var target: Target
            switch $0 {
            case .app:
                target = Target(
                    name: name,
                    platform: platform,
                    product: .app,
                    bundleId: "io.tuist.\(name)",
                    infoPlist: .extendingDefault(with: infoPlist),
                    sources: ["Sources/**"],
                    resources: ["Resources/**"],
                    dependencies: dependencies
                )
            case .unitTests:
                target = Target(
                    name: "\(name)Tests",
                    platform: platform,
                    product: .unitTests,
                    bundleId: "io.tuist.\(name)Tests",
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [
                        .target(name: "\(name)")
                ])
            case .uiTests:
                target = Target(
                    name: "\(name)UITests",
                    platform: platform,
                    product: .unitTests,
                    bundleId: "io.tuist.\(name)UITests",
                    infoPlist: .default,
                    sources: ["UITests/**"],
                    dependencies: [
                        .target(name: "\(name)")
                ])
            case .framework, .staticFramework:
                target = Target(
                    name: name,
                    platform: platform,
                    product: $0,
                    bundleId: "io.tuist.\(name)",
                    infoPlist: .extendingDefault(with: infoPlist),
                    sources: ["Sources/**"],
                    resources: $0 == .framework ? ["Targets/\(name)/Resources/**"] : nil,
                    dependencies: dependencies
                )
            case .dynamicLibrary, .staticLibrary:
                target = Target(
                    name: name,
                    platform: platform,
                    product: $0,
                    bundleId: "io.tuist.\(name)",
                    infoPlist: .extendingDefault(with: infoPlist),
                    sources: ["Sources/**"],
                    resources: nil,
                    dependencies: dependencies
                )
            default: return
            }
            targets.append(target)
        }
        
        if includeDemoApp {
            let target = Target(
                name: "\(name)DemoApp",
                platform: platform,
                product: .app,
                bundleId: "io.tuist.\(name)DemoApp",
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Sources/**"],
                resources: ["Resources/**"],
                dependencies: dependencies
            )
            targets.append(target)
            
            let scheme = Scheme(
              name: "\(name)DemoApp",
              buildAction: .init(targets: ["\(name)DemoApp"]),
              runAction: .runAction(executable: "\(name)DemoApp")
            )
            schemes.append(scheme)
        }
        
        return Project(name: name, targets: targets, schemes: schemes)
    }
}
