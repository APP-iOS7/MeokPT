import ProjectDescription

let project = Project(
    name: "MeokPT",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
  ),
    targets: [
        .target(
            name: "MeokPT",
            destinations: .iOS,
            product: .app,
            bundleId: "kr.co.codegrove.MeokPT",
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
            dependencies: [
                .external(name: "ComposableArchitecture"),
            ]
        ),
        .target(
            name: "MeokPTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "kr.co.codegrove.MeokPTTests",
            infoPlist: .default,
            sources: ["MeokPT/Tests/**"],
            resources: [],
            dependencies: [.target(name: "MeokPT")]
        ),
    ]
)
