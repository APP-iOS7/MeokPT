// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "MeokPT",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.19.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.12.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.3.2"),
    ]
)
