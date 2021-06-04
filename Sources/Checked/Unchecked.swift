import Decoded

@dynamicMemberLookup
public struct Unchecked<T> {
    let decoded: Decoded<T>

    var value: T? {
        try? decoded.state.getValue()
    }

    public var codingPath: [BasicCodingKey] { decoded.codingPath }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U? {
        value?[keyPath: keyPath]
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Unchecked<U>? {
        value.map { .init(decoded: $0[keyPath: keyPath]) }
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U? {
        try? value?[keyPath: keyPath].state.getValue()
    }
}

extension Decoded {
    public func unchecked() -> Unchecked<T> {
        .init(decoded: self)
    }
}

extension Unchecked {
    public func checked(mergingErrors additional: KeyedErrors = [:]) throws -> Checked<T> {
        if let error = DecodingErrors(keyedErrors: decoded.keyedErrors().merging(additional, uniquingKeysWith: +)) {
            throw error
        }
        return .init(unchecked: self)
    }
}
