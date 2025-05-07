import ProjectDescription

let project = Project(
    name: "MeokPT",
    targets: [
        .target(
            name: "MeokPT",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.MeokPT",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["MeokPT/Sources/**"],
            resources: ["MeokPT/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "MeokPTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.MeokPTTests",
            infoPlist: .default,
            sources: ["MeokPT/Tests/**"],
            resources: [],
            dependencies: [.target(name: "MeokPT")]
        ),
    ]
)
