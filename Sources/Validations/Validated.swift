import Decoded

/// A proxy for a successfully decoded and validated value.
///
/// A `Validated` value can only be created by calling `validate` on a `Decoded` value free from decoding and validation errors.
/// This proxy provides convenient access to the underlying value through the use of `@dynamicMemberLookup`.
///
/// ```swift
/// struct Package: Decodable {
///      let contents: Int
/// }
///
/// let validatedPackage: Validated<Package> = ...
/// 
/// // direct access to `contents`! (when the type is known)
/// let validatedContents: Int = validatedPackage.contents
/// ```
///
/// Direct access also works for nested objects, sequences, and dictionaries.
@dynamicMemberLookup
public struct Validated<T> {
    let decoded: Decoded<T>

    fileprivate init(_ decoded: Decoded<T>) throws {
        self.decoded = decoded
    }
}

public extension Validated {
    /// Unwraps the validated value.
    var unwrapped: T {
        try! decoded.unwrapped
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        unwrapped[keyPath: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Validated<U> {
        try! .init(unwrapped[keyPath: keyPath])
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U {
        unwrapped[keyPath: keyPath].value!
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>?>) -> Validated<U>? {
        try! unwrapped[keyPath: keyPath].map(Validated<U>.init)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>?>) -> U? {
        unwrapped[keyPath: keyPath]?.value!
    }
}

public extension Validated where T: Sequence, T.Element: Unwrappable {
    /// Unwraps the elements of the sequence of `Decoded` values as an `Array` of pure values.
    var unwrapped: [T.Element.Unwrapped] {
        try! unwrapped.unwrapped
    }
}

public extension Validated where T: Unwrappable {
    /// Unwraps the validated value as defined by its type.
    var unwrapped: T.Unwrapped {
        try! unwrapped.unwrapped
    }
}

extension Decoded {
    func validated(mergingFailures additional: KeyedFailuresRepresentable?) throws -> Validated<T> {
        if let keyedFailures = keyedFailures.merging(additional) {
            throw keyedFailures
        }

        return try .init(self)
    }
}

extension Validated: Decodable where T: Decodable {
    /// Provides a shorthand for decoding and validating a type with one statement.
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        self = try Decoded<T>(from: decoder).validated()
    }
}
