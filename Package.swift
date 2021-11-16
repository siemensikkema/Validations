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
        .package(name: "Decoded", url: "https://github.com/siemensikkema/Decoded.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "Validations",
            dependencies: ["Decoded"]
        ),
        .testTarget(
            name: "ValidationsTests",
            dependencies: ["Validations"]
        ),
    ]
)
