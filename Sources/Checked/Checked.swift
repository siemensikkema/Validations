import Decoded

@dynamicMemberLookup
public struct Checked<T> {
    let decoded: Decoded<T>

    fileprivate init(decoded: Decoded<T>) {
        self.decoded = decoded
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        try! decoded[dynamicMember: keyPath]
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Checked<U> {
        try! .init(decoded: decoded[dynamicMember: keyPath])
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U {
        try! decoded[dynamicMember: keyPath]
    }
}

extension Decoded {
    public func checked(mergingErrors additional: KeyedErrors? = nil) throws -> Checked<T> {
        if let keyedErrors = keyedErrors().merging(additional) {
            throw keyedErrors
        }

        return .init(decoded: self)
    }
}
