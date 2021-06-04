// swift-tools-version:5.4
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
            name: "Checked",
            dependencies: ["Decoded"]
        ),
        .target(
            name: "Decoded",
            dependencies: []
        ),
        .target(
            name: "Validations",
            dependencies: ["Checked"]
        ),
        .testTarget(
            name: "CheckedTests",
            dependencies: ["Checked"]
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
