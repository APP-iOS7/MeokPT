import ProjectDescription

let project = Project(
    name: "MeokPT",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": ["-ObjC"]
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
                .external(name: "FirebaseStorage")
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
