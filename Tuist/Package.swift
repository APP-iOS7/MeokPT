// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "FirebaseStorage": .framework,
            "ComposableArchitecture": .framework,
            "Dependencies": .framework,
            "CombineSchedulers": .framework,
            "Sharing": .framework,
            "SwiftUINavigation": .framework,
            "UIKitNavigation": .framework,
            "UIKitNavigationShim": .framework,
            "ConcurrencyExtras": .framework,
            "Clocks": .framework,
            "CustomDump": .framework,
            "IdentifiedCollections": .framework,
            "XCTestDynamicOverlay": .framework,
            "IssueReporting": .framework,
            "_CollectionsUtilities": .framework,
            "PerceptionCore": .framework,
            "Perception": .framework,
            "OrderedCollections": .framework,
            "CasePaths": .framework,
            "DependenciesMacros": .framework
            ]
    )
#endif

let package = Package(
    name: "MeokPT",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.19.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.12.0"),
    ]
)
