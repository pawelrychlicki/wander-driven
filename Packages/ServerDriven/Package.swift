// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ServerDriven",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "ServerDrivenKit",
            targets: ["ServerDrivenKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0"
        )
    ],
    targets: [
        .target(
            name: "ServerDrivenKit",
            dependencies: ["ServerDrivenMacros"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted")
            ]
        ),
        .macro(
            name: "ServerDrivenMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted")
            ]
        ),
        .testTarget(
            name: "ServerDrivenKitTests",
            dependencies: ["ServerDrivenKit"],
            resources: [
                .process("Fixtures")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted")
            ]
        ),
        .testTarget(
            name: "ServerDrivenMacrosTests",
            dependencies: [
                "ServerDrivenKit",
                "ServerDrivenMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted")
            ]
        )
    ]
)
