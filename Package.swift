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
        .target(
            name: "Common",
            dependencies: ["Decoded"],
            path: "Tests/Common"
        ),
        .testTarget(
            name: "DecodedTests",
            dependencies: ["Decoded", "Common"]
        ),
        .testTarget(
            name: "ValidationsTests",
            dependencies: ["Validations", "Common"]
        ),
    ]
)
