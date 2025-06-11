import ProjectDescription
import Foundation

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
                            "CFBundleURLSchemes": ["kakao\(String(describing: (loadKakaoKey())))"]
                        ]
                    ],
                    "NSCameraUsageDescription": "바코드를 스캔하여 식품 정보를 조회하기 위해 카메라 권한이 필요합니다.",
                    "KAKAO_SDK_KEY": .string(loadKakaoKey())
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

private func loadKakaoKey() -> String {
    let fileURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent(".tuist-env")
    
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
          let line = content.components(separatedBy: .newlines)
            .first(where: { $0.hasPrefix("KAKAO_SDK_KEY=") }) else {
        return ""
    }
    
    return String(line.dropFirst("KAKAO_SDK_KEY=".count))
}
