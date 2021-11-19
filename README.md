# Validations

Type-safe and composable validations with versatile output.

See the [full documentation](https://validations.siemensikkema.nl). 

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
