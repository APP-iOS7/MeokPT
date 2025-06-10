import ProjectDescription

let project = Project(
    name: "MeokPT",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "59FP2PXRXK",
        ],
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
            bundleId: "kr.co.codegrove.MeokPTApp",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "LSApplicationQueriesSchemes": [
                        "kakaokompassauth": true
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLSchemes": ["kakaoe45aac872cc22f70369464e409b9b04b"]
                        ]
                    ],
                    "NSCameraUsageDescription": "바코드를 스캔하여 식품 정보를 조회하기 위해 카메라 권한이 필요합니다."
                ]
            ),
            sources: ["MeokPT/Sources/**"],
            resources: ["MeokPT/Resources/**"],
            entitlements: .file(path: "MeokPT.entitlements"),
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseStorage"),
                .external(name: "Kingfisher"),
                .external(name: "FirebaseAI"),
                .external(name: "MarkdownUI"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "AlertToast")
            ]
        ),
        .target(
            name: "MeokPTTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "kr.co.codegrove.MeokPTAppTests",
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
