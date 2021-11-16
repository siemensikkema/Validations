import Decoded

/// A value that is guaranteed to have passed some validation.
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
    public init(from decoder: Decoder) throws {
        self = try Decoded<T>(from: decoder).validated()
    }
}
