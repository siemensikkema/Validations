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
        .target(
            name: "Common",
            dependencies: ["Decoded"],
            path: "Tests/Common"
        ),
        .testTarget(
            name: "CheckedTests",
            dependencies: ["Checked", "Common"]
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
