// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Validations",
    products: [
        .library(
            name: "Validations",
            targets: ["Validations"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Decoded",
            dependencies: []
        ),
        .target(
            name: "Validations",
            dependencies: ["Decoded"]
        ),
        .testTarget(
            name: "DecodedTests",
            dependencies: ["Decoded"]
        ),
        .testTarget(
            name: "ValidationsTests",
            dependencies: ["Validations"]
        ),
    ]
)
