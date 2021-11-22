# Validations

[![CI](https://github.com/siemensikkema/Validations/actions/workflows/ci.yml/badge.svg)](https://github.com/siemensikkema/Validations/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsiemensikkema%2FValidations%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/siemensikkema/Validations)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsiemensikkema%2FValidations%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/siemensikkema/Validations)

Type-safe and composable validations with versatile output.

# Installation

Add `Validations` to your `Package.swift` file.

```swift
dependencies: [
    ...
    .package(url: "https://github.com/siemensikkema/Validations.git", from: "0.2.0"),
]
...
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            ...
            "Validations",
        ]
    )
]
```

Import `Decoded` and `Validations` to any file you want to use this library in.

```swift
import Decoded
import Validations
```

# Documentation
This library's documentation is created using [DocC](https://developer.apple.com/documentation/docc) and can be found [here](https://validations.siemensikkema.nl).
