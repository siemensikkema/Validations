import Decoded

@dynamicMemberLookup
public struct Validated<T> {
    let decoded: Decoded<T>

    fileprivate init(_ decoded: Decoded<T>) throws {
        self.decoded = decoded
    }
}

public extension Validated {
    private var value: T {
        try! decoded.unwrapped
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        value[keyPath: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Validated<U> {
        try! .init(value[keyPath: keyPath])
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U {
        value[keyPath: keyPath].value!
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>?>) -> Validated<U>? {
        try! value[keyPath: keyPath].map(Validated<U>.init)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>?>) -> U? {
        value[keyPath: keyPath]?.value!
    }
}

public extension Validated where T: Sequence {
    func unwrapped<U>() -> [U] where T.Element == Decoded<U> {
        try! value.unwrapped()
    }
}

public extension Validated {
    func unwrapped<Key, Value>() -> [Key: Value] where T == [Key: Decoded<Value>] {
        try! value.unwrapped()
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
