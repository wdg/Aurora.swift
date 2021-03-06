// swift-tools-version:5.3

import PackageDescription

/// Aurora framework for Swift.
let package = Package(
    /// Aurora Framework
    name: "Aurora",
    
    /// It is created for:
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    
    /// It is a framework/library
    products: [
        .library(
            name: "Aurora",
            targets: ["Aurora"]
        )
    ],
    
    /// Hopefully this will never get bigger than 0
    dependencies: [],
    
    /// The targets are:
    targets: [
        .target(
            name: "Aurora",
            dependencies: [],
            exclude: [
                "build",
                "docs",
                "checkFirstRows.php",
                "generateDocumentation.command",
                "README.md"
            ],
            resources: [
                .process("Resources/NSFW.mlmodel")
            ]
        ),
        .testTarget(
            name: "AuroraTests",
            dependencies: [
                "Aurora"
            ],
            exclude: [
                "build",
                "docs",
                "checkFirstRows.php",
                "generateDocumentation.command",
                "README.md"
            ],
            resources: [
                .process("Resources/NSFW.mlmodel")
            ]
        )
    ]
)
