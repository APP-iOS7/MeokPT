import ProjectDescription

let project = Project(
    name: "MeokPT",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [:],
        configurations: [
            .debug(
                name: "Debug",
                xcconfig: .relativeToRoot("Configurations/App/App-Debug.xcconfig")
            ),
            .release(
                name: "Release",
                xcconfig: .relativeToRoot("Configurations/App/App-Release.xcconfig")
            )
        ]
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
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                ]
            ),
            sources: ["MeokPT/Sources/**"],
            resources: ["MeokPT/Resources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseStorage"),
                .external(name: "Kingfisher"),
                .external(name: "FirebaseAI"),
                .external(name: "MarkdownUI"),
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
    ],
    schemes: [
        Scheme.scheme(
            name: "MeokPT-Preview",
            shared: true,
            hidden: false,
            buildAction: BuildAction.buildAction(targets: ["MeokPT"]),
            runAction: RunAction.runAction(configuration: "Debug")
        ),

        Scheme.scheme(
            name: "MeokPT",
            shared: true,
            hidden: false,
            buildAction: BuildAction.buildAction(targets: ["MeokPT"]),
            runAction: RunAction.runAction(configuration: "Release"),
            archiveAction: ArchiveAction.archiveAction(configuration: "Release")
        )
    ]
)
